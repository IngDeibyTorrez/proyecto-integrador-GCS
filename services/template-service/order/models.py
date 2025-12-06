from django.db import models


class Order(models.Model):
    id = models.AutoField(primary_key=True)
    customer_id = models.IntegerField(null=True, db_column='customer_id')
    restaurant_id = models.IntegerField(null=True, db_column='restaurant_id')
    driver_id = models.IntegerField(null=True, db_column='driver_id')
    status_id = models.IntegerField(null=True, db_column='status_id')
    total_amount = models.DecimalField(max_digits=10, decimal_places=2, db_column='total_amount')
    delivery_fee = models.DecimalField(max_digits=8, decimal_places=2, null=True, db_column='delivery_fee')
    platform_fee = models.DecimalField(max_digits=8, decimal_places=2, null=True, db_column='platform_fee')
    discount_amount = models.DecimalField(max_digits=8, decimal_places=2, null=True, db_column='discount_amount')
    final_amount = models.DecimalField(max_digits=10, decimal_places=2, db_column='final_amount')
    delivery_address = models.TextField(db_column='delivery_address')
    notes = models.TextField(null=True, db_column='notes')
    created_at = models.DateTimeField(null=True, db_column='created_at')
    updated_at = models.DateTimeField(null=True, db_column='updated_at')

    class Meta:
        db_table = 'orders'
        managed = False

    def __str__(self):
        return f"Order {self.id} - {self.final_amount}"
