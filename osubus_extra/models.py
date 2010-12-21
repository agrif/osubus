from django.db import models

class ExternalLink(models.Model):
    name = models.CharField(max_length=200)
    url = models.URLField()
    
    def __unicode__(self):
        return self.name

class Screenshot(models.Model):
    image = models.ImageField(upload_to="screenshots/")
    title = models.CharField(max_length=200)
    description = models.TextField(max_length=1024)
    
    def __unicode__(self):
        return self.title
