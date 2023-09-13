import boto3
from io import StringIO

class aws_connector:

    s3_bucket = ''
    project = ''
    s3 = boto3.client('s3')

    def __init__(self, s3_bucket:str = '', project:str = '', ):
        self.s3_bucket = s3_bucket
        self.project = project

    def put_s3_csv(self, data, filename:str):
        print("Storing the data into:")
        print(f'{self.project}/{filename}')
        csv_buffer=StringIO()
        data.to_csv(csv_buffer)
        content = csv_buffer.getvalue()
        self.s3.put_object(Body=content, Bucket=self.s3_bucket, Key=f'{self.project}/{filename}')