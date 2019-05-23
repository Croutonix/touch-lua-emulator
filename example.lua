-- Clock
function main()
   draw.setscreen(1)
   draw.settitle('Clock')

   while true do
      draw.doevents()
      draw.beginframe()
      draw.clear()
      getTime()
      drawClock()
      draw.endframe()
      draw.sleep(250)
   end
end

function drawClock()
   draw.setantialias(false)

   -- Draw the clock border
   draw.setlinestyle(2, 'round')
   draw.circle(px, py, radius, draw.black)

   -- Draw lines around the clock
   for i = 1, 60 do
      a = i*6 * math.pi/180
      b = 10 draw.setlinestyle(2, 'round')
      if i%5 == 0 then b = 15 draw.setlinestyle(3, 'round') end
      x1, y1 = px+(radius-1)*math.cos(a), py+(radius-1)*math.sin(a)
      x2, y2 = px+(radius-b)*math.cos(a), py+(radius-b)*math.sin(a)
      draw.line(x1, y1, x2, y2, draw.black)
   end

   -- Draw the hands
   angle, color = {}, {draw.darkgray, gray, red}
   angle[1] = (hour*6 + min/10 - 90) * math.pi / 180
   angle[2] = (min*6 + sec/10 - 90) * math.pi / 180
   angle[3] = (sec*6 - 90) * math.pi / 180
   for i = 1, 3 do
      draw.setlinestyle(7-i, 'round')
      draw.line(px, py, px+(radius-(5-i)*10)*math.cos(angle[i]), py+(radius-(5-i)*10)*math.sin(angle[i]), color[i])
   end

   -- Draw the clock's center
   draw.setlinestyle(10, 'round')
   draw.point(px, py, draw.black)

   -- Print time
   draw.setantialias(true)
   if string.len(sec) == 1 then sec = '0'..sec end
   if string.len(min) == 1 then min = '0'..min end
   if string.len(hour) == 1 then hour = '0'..hour end
   a = hour..':'..min..':'..sec
   draw.setfont('GillSans', 40)
   w = draw.stringsize(a)
   draw.string(a, px-w/2, py+radius+10, draw.black)

   -- Print date
   a = month..' '..day
   w, h = draw.stringsize(a)
   draw.string(a, px-w/2, py-radius-h-10, draw.black)
end

function getTime()
   time = os.date('*t')
   hour, min, sec = time.hour, time.min, time.sec
   month, day = months[time.month], time.day
   drawClock()
end

-- Months
months = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'}

-- Half transparent colors (hands)
red = {1, 0, 0, 0.5}
gray = {0.5, 0.5, 0.5, 0.5}

-- Size and position
px = draw.getport()
px, py = px/2, 250
radius = 120

main()