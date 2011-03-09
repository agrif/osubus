from django.db import models
from django.core.files.move import file_move_safe
import random, string, datetime

try:
    import sqlite3
except ImportError:
    try:
        from pysqlite2 import dbapi2 as sqlite3
    except ImportError:
        raise Exception("sqlite3 module not found.")

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

PRIORITY_CHOICES = (
    (0, 'Low'),
    (1, 'Medium'),
    (2, 'High'),
)

class MetaBulletin(models.Model):
    title = models.CharField(max_length=200)
    priority = models.PositiveSmallIntegerField(choices=PRIORITY_CHOICES, default=0)
    body = models.TextField(max_length=8192)
    
    def __unicode__(self):
        return self.title
    
    class Meta:
        abstract = True

class Bulletin(MetaBulletin):
    pass

class VersionBulletin(MetaBulletin):
    major = models.PositiveSmallIntegerField()
    minor = models.PositiveSmallIntegerField()
    revision = models.PositiveSmallIntegerField()
    
    def __unicode__(self):
        return str(self.major) + '.' + str(self.minor) + '.' + str(self.revision)
    
    class Meta(MetaBulletin.Meta):
        unique_together = (('major', 'minor', 'revision'),)
        ordering = ['-major', '-minor', '-revision']

class VersionStats(models.Model):
    major = models.PositiveSmallIntegerField(editable=False)
    minor = models.PositiveSmallIntegerField(editable=False)
    revision = models.PositiveSmallIntegerField(editable=False)
    dbversion = models.PositiveSmallIntegerField(editable=False)
    dbdate = models.DateField(editable=False)
    
    date = models.DateField(editable=False)
    count = models.PositiveIntegerField()
    
    @classmethod
    def increment(cls, version, dbversion, dbdate):
        major, minor, revision = version
        kwargs = {"major" : major, "minor" : minor, "revision" : revision}
        kwargs["dbversion"] = dbversion
        kwargs["dbdate"] = dbdate
        kwargs["date"] = datetime.date.today()
        
        try:
            mod = cls.objects.get(**kwargs)
        except cls.DoesNotExist:
            mod = cls(**kwargs)
            mod.count = 0
        
        mod.count = mod.count + 1
        mod.save()
    
    def __unicode__(self):
        return "(%s) %i.%i.%i" % (self.date, self.major, self.minor, self.revision)
    
    class Meta:
        unique_together = (('dbversion', 'dbdate', 'major', 'minor', 'revision', 'date'),)
        ordering = ['-date', '-major', '-minor', '-revision']
        verbose_name_plural = "version stats"

def database_get_upload_path(instance=None, filename=None):
    # temporary path so we can read it later
    return 'databases/tmp.' + ''.join(random.sample(string.ascii_uppercase + string.digits, 6)) + '.db'

class CacheDatabase(models.Model):
    version = models.PositiveSmallIntegerField(editable=False)
    date = models.DateField(editable=False)
    file = models.FileField(upload_to=database_get_upload_path)
    
    class Meta:
        unique_together = (('date', 'version'),)
        ordering = ['-date', '-version']
        
    def save(self, *args, **kwargs):
        # temporary values for version, date
        self.version = 0
        self.date = datetime.date.today()
        super(CacheDatabase, self).save(*args, **kwargs)

        conn = sqlite3.connect(self.file.path)
        c = conn.cursor()
        
        c.execute("SELECT name, value FROM meta")
        date = None
        version = None
        for i in c.fetchall():
            if i[0] == 'version':
                version = i[1]
            if i[0] == 'date':
                date = i[1]
        
        try:
            if not version:
                raise ValueError
            self.version = int(version)
        except ValueError:
            raise models.IntegrityError('database does not list valid version')
        
        try:
            if not date:
                raise ValueError
            # MM/DD/YYYY (unfortunately... grr...)
            date = map(int, date.split('/', 2))
            if len(date) != 3:
                raise ValueError
            self.date = datetime.date(date[2], date[0], date[1])
        except ValueError:
            raise models.IntegrityError('database does not list valid date')
        
        c.close()
        conn.close()
        
        # move the file, if needed
        if self.file.name.startswith('databases/tmp.'):
            newpath = 'databases/' + str(self)
            newpathreal = self.file.storage.path(newpath)
            file_move_safe(self.file.path, newpathreal)
            self.file = newpath
        
        # resave
        super(CacheDatabase, self).save(*args, **kwargs)
    
    def __unicode__(self):
        return "v%i.%s.db" % (self.version, str(self.date))
