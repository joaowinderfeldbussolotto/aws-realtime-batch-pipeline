import json
import http.client
from urllib.parse import urlparse
import boto3
import os

# API Configuration
LATITUDE = float(os.getenv('LATITUDE'))
LONGITUDE = float(os.getenv('LONGITUDE'))
TOMORROW_API_KEY = os.getenv('TOMORROW_API_KEY')
API_URL = f"https://api.tomorrow.io/v4/weather/realtime?location={LATITUDE},{LONGITUDE}&apikey={TOMORROW_API_KEY}"
PARSED_URL = urlparse(API_URL)

# Kinesis Configuration
STREAM_NAME = os.getenv('KINESIS_NAME')
kinesis_client = boto3.client('kinesis')

def get_weather_data():
    conn = http.client.HTTPSConnection(PARSED_URL.netloc)
    try:
        conn.request("GET", PARSED_URL.path + "?" + PARSED_URL.query, 
                    headers={"accept": "application/json"})
        response = conn.getresponse()
        return json.loads(response.read().decode())
    finally:
        conn.close()

def lambda_handler(event, context):
    try:
        weather_data = get_weather_data()
        
        kinesis_client.put_record(
            StreamName=STREAM_NAME,
            Data=json.dumps(weather_data),
            PartitionKey="partition_key"
        )
        
        print(weather_data)
        return {
            'statusCode': 200,
            'body': json.dumps('Dados enviados ao Kinesis com sucesso')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }

if __name__ == "__main__":
    lambda_handler(None, None)