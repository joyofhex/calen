# Calen

A simple app to look at exchange meeting room reservations.

## Usage

First, calen looks at a file named ~/.jira for your corporate credentials. It is a yaml file formatted as such:

  ---
  username: corp_username
  password: your_password_here

There are two ways you can use calen.

First, is an overview of booked rooms for a given day:

  $ calen -d tomorrow -s DRK
  Room Availability on 2014-05-23 from 08:00 until 18:00
  Room                           |08:00  |10:00  |12:00  |14:00  |16:00  |18:00
  MR-NL-DRK-01 1.14 8p - beamer: |...|.**********|...|.******|...|...|...|
  MR-NL-DRK-01 1.15 6p - beamer: |...|.****..|...|...|...|...|...|...|...|
  MR-NL-DRK-01 1.16 6p - beamer: |...********************************|...|

If you provide a time and a meeting length, calen will list meeting rooms with availability during that slot:

  $ calen -d '29th may' -t 1300 -l 4h
  Available rooms on 2014-05-29 at 13:00 for 4 hrs (ending at 17:00)
    MR-NL-ODE-02 Bois de Boulogne 10p - x75602
    MR-NL-ODE-02 Central Park 1 (VC) 15p - screen - x75659
    MR-NL-ODE-02 Central Park 2 15p - screen - x75634


## Options 

  Usage: $0 [options]
      -s, --site SITE                  SITE to search for rooms
      -d, --date DATE                  DATE to search
          --work-day-start-time TIME   TIME for the beginning of the day
          --work-day-end-time TIME     TIME for the end of the day
      -l, --length DURATION            Length of meeting
      -t, --time TIME                  Start time of the meeting
