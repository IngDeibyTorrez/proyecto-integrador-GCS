from django.http import JsonResponse, HttpResponseBadRequest, HttpResponseNotAllowed
from .models import Order
import json
from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import get_object_or_404
from django.utils import timezone


@csrf_exempt
def lista(request):
    if request.method == 'GET':
        data = list(Order.objects.values())
        return JsonResponse({'orders': data})
    elif request.method == 'POST':
        try:
            payload = json.loads(request.body.decode('utf-8'))
        except json.JSONDecodeError:
            return HttpResponseBadRequest('JSON inválido')

        # Campos mínimos esperados para crear una orden
        required = ['customer_id', 'restaurant_id', 'total_amount', 'final_amount', 'delivery_address']
        missing = [f for f in required if f not in payload]
        if missing:
            return HttpResponseBadRequest(f'Faltan campos: {missing}')

        # Extraer campos y valores opcionales
        customer_id = payload.get('customer_id')
        restaurant_id = payload.get('restaurant_id')
        driver_id = payload.get('driver_id')
        status_id = payload.get('status_id', 1)
        total_amount = payload.get('total_amount')
        delivery_fee = payload.get('delivery_fee', 0)
        platform_fee = payload.get('platform_fee', 0)
        discount_amount = payload.get('discount_amount', 0)
        final_amount = payload.get('final_amount')
        delivery_address = payload.get('delivery_address')
        notes = payload.get('notes')

        # Crear registro en la tabla existente 'orders'
        order = Order.objects.create(
            customer_id=customer_id,
            restaurant_id=restaurant_id,
            driver_id=driver_id,
            status_id=status_id,
            total_amount=total_amount,
            delivery_fee=delivery_fee,
            platform_fee=platform_fee,
            discount_amount=discount_amount,
            final_amount=final_amount,
            delivery_address=delivery_address,
            notes=notes,
            created_at=timezone.now(),
            updated_at=timezone.now(),
        )

        return JsonResponse({'id': order.id, 'final_amount': str(order.final_amount)}, status=201)
    else:
        return HttpResponseNotAllowed(['GET', 'POST'])


def detalle(request, pk):
    if request.method != 'GET':
        return HttpResponseNotAllowed(['GET'])
    order = get_object_or_404(Order, pk=pk)
    # Devolver los campos más relevantes
    return JsonResponse({
        'id': order.id,
        'customer_id': order.customer_id,
        'restaurant_id': order.restaurant_id,
        'driver_id': order.driver_id,
        'status_id': order.status_id,
        'total_amount': str(order.total_amount),
        'delivery_fee': str(order.delivery_fee) if order.delivery_fee is not None else None,
        'platform_fee': str(order.platform_fee) if order.platform_fee is not None else None,
        'discount_amount': str(order.discount_amount) if order.discount_amount is not None else None,
        'final_amount': str(order.final_amount),
        'delivery_address': order.delivery_address,
        'notes': order.notes,
        'created_at': order.created_at.isoformat() if order.created_at else None,
        'updated_at': order.updated_at.isoformat() if order.updated_at else None,
    })
