from django.shortcuts import render_to_response
from django.template import RequestContext
from osubus_extra.models import Screenshot

def screenshots(request):
    all_shots = Screenshot.objects.all()
    return render_to_response('screenshots.html', {'screenshots' : all_shots}, context_instance=RequestContext(request))

