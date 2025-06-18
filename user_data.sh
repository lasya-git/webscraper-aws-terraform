#!/bin/bash
yum update -y
yum install -y python3
yum install -y python3-pip
yum install -y cronie
systemctl start crond
systemctl enable crond
pip3 install requests beautifulsoup4 pandas lxml boto3
 
mkdir -p /home/ec2-user/webscraper
cd /home/ec2-user/webscraper

cat <<EOF > main.py
from bs4 import BeautifulSoup
import requests
import re
import pandas as pd
import boto3

def get_book_info():
    html_text = requests.get('https://hardcover.app/trending/month').text
    soup = BeautifulSoup(html_text, 'lxml')
    books = soup.find_all('div', class_ = 'flex flex-row space-x-2 w-full')

    book_info = []
    for book in books:
        info = book.find('p', class_ = 'text-gray-600 dark:text-gray-400 text-sm font-semibold mt-2').text.replace(' ', '').split('•')
        rating = float(info[3])
        if rating >= 3.8:
            title = book.find('div', class_ = 'flex-grow').a.text
            author = book.find('span', class_ = 'flex-inline flex-row mr-1').a.span.text
            readers = re.search(r'[\d,]+', info[1]).group()
            url = 'hardcover.app'+book.find('div', class_ = 'flex-grow').div.a['href']
            book_info.append({'title': title, 'author': author, 'readers': readers, 'rating': rating, 'url': url})
    df = pd.DataFrame(book_info) 
    filename = 'bookinfo.csv'
    df.to_csv(filename, index = True, index_label = 'id')
    print(f"{filename} saved")   

    s3 = boto3.client('s3')
    bucket_name = 'scraped-book-info-output'
    s3.upload_file(filename, bucket_name, filename)
    print(f"{filename} uploaded to s3")
    

if __name__ == '__main__':
    get_book_info()
    print("Book info retrieved.") 
EOF

chmod 755 /home/ec2-user/webscraper/main.py
chown ec2-user:ec2-user /home/ec2-user/webscraper/main.py

su - ec2-user -c "echo '0 20 * * * /usr/bin/python3 /home/ec2-user/webscraper/main.py >> /home/ec2-user/webscraper/scraper.log 2>&1' | crontab -"
