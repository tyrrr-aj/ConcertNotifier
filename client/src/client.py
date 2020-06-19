import grpc
import sys
import time

from ConcertNotifier_pb2 import SubscriptionRequest, ConcertEvent
from gen.ConcertNotifier_pb2_grpc import ConcertNotifierStub


all_cities = ["Kraków", "Katowice", "Wrocław", "Łódź", "Warszawa", "Poznań", "Gdańsk", "Toruń"]
all_bands = ["Epica", "Nightwish", "Delain", "Amon Amarth", "Arch Enemy", "Dark Oath", "Sabaton", "Blind Guardian",
            "Hammerfall", "Metallica", "Anthrax", "Slayer", "Van Canto", "Ayreon", "Symphony X"]
all_genres = ['SYMPHONIC_METAL', 'MELODIC_DEATH_METAL', 'POWER_METAL', 'THRASH_METAL', 'ACAPELLA_METAL', 'PROG_METAL']


def main():
    line = input("Enter bands you're interested in, separated with commas:\n")
    bands = [s.strip().title() for s in line.split(',') if s.strip() != ''] if line != 'all' else all_bands
    line = input("Enter cities you're interested in, separated with commas:\n")
    cities = [s.strip().title() for s in line.strip().split(',') if s.strip() != ''] if line != 'all' else all_cities
    line = input("Enter genres you're interested in, separated with commas:\n")
    genres = [s.strip().replace(' ', '_').upper() for s in line.split(',') if s.strip() != ''] if line != 'all' else all_genres

    port = sys.argv[1] if len(sys.argv) >= 2 else 10000
    print(f'Connecting to localhost:{port}')
    channel = grpc.insecure_channel(f'127.0.0.1:{port}', options=[
        ("grpc.keepalive_time_ms", 10000),
        ("grpc.keepalive_timeout_ms", 5000),
        ("grpc.keepalive_permit_without_calls", 1),
        ("grpc.http2.max_pings_without_data", 0),
        ("grpc.http2.min_sent_ping_interval_without_data_ms", 10000) ])
    notifier = ConcertNotifierStub(channel)

    request = SubscriptionRequest(City=cities, Band=bands, Genre=genres)

    # request = SubscriptionRequest(City=['Kraków', 'Katowice', 'Wrocław', 'Łódź', 'Poznań', 'Warszawa', 'Gdańsk', 'Toruń'],
    #                               Band=['Epica', 'Nightwish', 'Delain', 'Amon Amarth', 'Arch Enemy', 'Dark Oath', 'Sabaton',
    #                                     'Hammerfall', 'Blind Guardian', 'Metallica', 'Anthrax', 'Slayer', 'Van Canto', 'Ayreon', 'Symphony X']
    #                             )

    print('Sending request...')

    max_interval = 15.0
    interval = 0.1

    while True:
        try:
            stream_it = iter(notifier.TrackConcerts(request))
            first_concert = next(stream_it)
            print('Connection successful')
            interval = 0.1
            print(f'{first_concert.Band} are going to play in {first_concert.City}')
            for concert in stream_it:
                print(f'{concert.Band} are going to play in {concert.City}')
        except:
            print(f'ERROR: Connection with server lost, trying to recover in {interval} seconds...')
            time.sleep(interval)
            print(f'Trying to recover')
            interval = interval * 2 if interval * 2 < max_interval else max_interval


if __name__ == "__main__":
    main()