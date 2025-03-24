Author: Calvin Lynch - K00271788
Project - Air Quality Metrics Using A Raspberry Pi 5

Mobile App Developed Using SwiftUI. 

App Shows live data(Co2 & Particulate Matter) & refreshes every 15 seconds. 

App uses Rest-Api's to fetch data & display the results.

Requirements: Ensure rest server is up & running & is fetching data from the influx database.

Requirements: XCode IDE(MAC).

In source code update Ip address on line 37 in /AQI App/Preview Content/view_live_data.swift - This is for your rest server/web server as this is needed to fetch data.

To Run this Mobile App:

As this application is in development & not publically availabile.

Clone this code onto your local machine.

Open XCode IDE - Open this folder.

Make sure to have an Iphone with dev tools enabled. Min iphone ios version 15. 

Plug Iphone into computer/desktop(where XCode is downloaded & running)

Choose destination where to run  code. Your device(iPhone) should show up as a device to run the code on if your iPhone is plugged in.

Press Run, this will build the app on your iphone. When built locate it omn your iphone(AQI App), click it(make sure your phone is connected to a network/wi-fi)

This will load & bring you to the welcome screen.

On the bottom of the screen there are 2 tabs, first is home & the second is live data which when clicked will bring you too the live data screen.

Assuming your FastApi is up & running correctly, you should see data updating live on your screen.

In the event of no data - Check your FastApi servers IP address & ensure that is accessible & it is able to communicate with your influx database. Check Raspberry Pi, is the Raspberry pi on & writing data to the influx datatbase.


Aim of this Mobile App:
Fetch & display real-time CO₂ & PM levels.
Show/Indicate good or bad air quality.
Provide recommendations based on air quality.
Enable data analysis & API integrations for other applications.

Alternatively if you do not have an iPhone(the frontend React Web App is avail to display data in a web application - Both apps consume Rest-Api's & the Api's can also be used for other apps or analysis)
