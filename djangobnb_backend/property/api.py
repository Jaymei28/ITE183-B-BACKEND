from django.http import JsonResponse

from rest_framework.decorators import api_view, authentication_classes, permission_classes

from .forms import PropertyForm
from .models import Property
from .serializers import PropertyListSerializers



@api_view(['GET'])
@authentication_classes([])
@permission_classes([])
def properties_list(request):
    properties = Property.objects.all()
    serializers = PropertyListSerializers(properties, many=True)

    return JsonResponse({
        'data': serializers.data
    })

@api_view(['POST', 'FILES'])
def create_property(request):
    form = PropertyForm(request.POST, request.FILES)

    if form.is_valid():
        property = form.save(commit=False)
        property.landlord = request.user
        property.save()
        
        return JsonResponse({'success': True, 'id': str(property.id)}, status=201)
    else:
        print('error', form.errors, form.non_field_errors)
        # Convert form errors to a proper dict format
        errors_dict = {}
        for field, error_list in form.errors.items():
            errors_dict[field] = [str(error) for error in error_list]
        
        return JsonResponse({'error': errors_dict}, status=400)