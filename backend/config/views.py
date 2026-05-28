import logging
from urllib.parse import urlencode

import requests
from django.http import HttpResponseBadRequest, JsonResponse

logger = logging.getLogger(__name__)

FRANKFURTER_LATEST_URL = "https://api.frankfurter.dev/v2/rates"

FRANKFURTER_BASE_URL = "https://api.frankfurter.dev/v2/rates?base=USD"


