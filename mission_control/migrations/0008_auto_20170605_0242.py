# -*- coding: utf-8 -*-
# Generated by Django 1.10.5 on 2017-06-05 02:42
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('mission_control', '0007_auto_20170605_0240'),
    ]

    operations = [
        migrations.AlterField(
            model_name='rover',
            name='local_ip',
            field=models.CharField(max_length=15),
        ),
        migrations.AlterField(
            model_name='rover',
            name='name',
            field=models.CharField(max_length=25),
        ),
    ]