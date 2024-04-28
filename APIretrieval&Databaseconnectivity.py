import requests
import sqlite3

def fetch_books():
    url = ""
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print("Failed to fetch data from the API")
        return None


def create_database(books):
    conn = sqlite3.connect("books.db")
    cursor = conn.cursor()

    
    cursor.execute('''CREATE TABLE IF NOT EXISTS Books (
                        id INTEGER PRIMARY KEY,
                        title TEXT,
                        author TEXT,
                        publication_year INTEGER
                    )''')

    
    for book in books:
        cursor.execute("INSERT INTO Books (title, author, publication_year) VALUES (?, ?, ?)",
                       (book["title"], book["author"], book["publication_year"]))

    
    conn.commit()
    conn.close()

def display_books():
    conn = sqlite3.connect("books.db")
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Books")
    books = cursor.fetchall()

    # Display fetched data
    print("Books:")
    for book in books:
        print(f"Title: {book[1]}, Author: {book[2]}, Publication Year: {book[3]}")

    conn.close()

def main():

    books_data = fetch_books()

    if books_data:
      
        create_database(books_data)

        
        display_books()

if __name__ == "__main__":
    main()
