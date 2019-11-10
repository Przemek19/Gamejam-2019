timers = {}

getTickCount = function()
  return math.ceil(socket.gettime() * 1000)
end

setTimer = function(func, ms, count, args)
  local timer = {}
  if not func then outputDebug("setTimer - brak funkcji w argumencie 1.") end
  timer.func = func
  timer.ms = ms
  timer.count = count
  timer.starts = getTickCount()
  timer.args = args
  timer.destroy = function(self)
    for i, t in pairs(timers) do
      if t == self then
        table.remove(timers, i)
      end
    end
  end
  table.insert(timers, timer)
  return timer
end

updateTimers = function()
  if #timers == 0 then return end
  for i, timer in pairs(timers) do
    if timer.starts + timer.ms < getTickCount() then
      timer.starts = getTickCount()
      if timer.count ~= 0 then
        if timer.count <= 1 then
          table.remove(timers, i)
        end
        timer.count = timer.count - 1
      end
      timer.func(timer.args)
    end
  end
end

isInteger = function(number)
  return number == math.ceil(number) or numer == math.floor(number)
end