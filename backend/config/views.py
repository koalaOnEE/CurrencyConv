import logging
from urllib.parse import urlencode

import requests
from django.http import HttpResponseBadRequest, JsonResponse

logger = logging.getLogger(__name__)

FRANKFURTER_LATEST_URL = "https://api.frankfurter.dev/v2/rates"

FRANKFURTER_BASE_URL = "https://api.frankfurter.dev/v2/rates?base=USD"

def exchange_rates(request):
    base_currency = request.GET.get('base', 'USD').upper()
    target_currencies = request.GET.get('targets', 'EUR,GBP').upper().split(',')
    
    url = f"https://api.frankfurter.dev/v2/rates?base={base_currency}"
    
    try: 
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        api_rates = {item['quote']: item['rate'] for item in data}
        rates = {currency: api_rates.get(currency) for currency in target_currencies}
        original_amount = float(request.GET.get('amount', 1))
        first_target_rate = list(rates.values())[0] if rates else None
        if first_target_rate is not None:
            converted_amount = original_amount * first_target_rate
        else:
            converted_amount = 0

        return JsonResponse({'original amount': original_amount, 'rates': rates, 'converted amount': converted_amount})
    except KeyError:
        return JsonResponse({'error': 'Invalid response from exchange rate API.'}, status=500)
    except requests.RequestException:
        return JsonResponse({'error': 'Failed to fetch exchange rates.'}, status=500)