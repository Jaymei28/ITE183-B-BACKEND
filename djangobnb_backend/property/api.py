from operator import truediv
from django.http import JsonResponse

from rest_framework.decorators import api_view, authentication_classes, permission_classes

from .models import Property
from .serializers import PropertyListSerializers
from . import serializers



@api_view(['GET'])
@authentication_classes([])
@permission_classes([])
def properties_list(request):
    properties = Property.objects.all()
    serializers = PropertyListSerializers(properties, many=True)

    return JsonResponse({
        'data': serializers.data
    })
