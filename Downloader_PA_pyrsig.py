"""
Get DataFrame for PurpleAir PM25
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
"""

import pyrsig

rsigapi = pyrsig.RsigApi(bdate='2020-12-31')
rsigapi.purpleair_kw['api_key'] = 'your_PurpleAir_API_key'

df = rsigapi.to_dataframe('purpleair.pm25_corrected')