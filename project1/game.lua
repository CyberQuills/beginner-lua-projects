tries = 6
number = math.random(1,100)

term.clear()
while tries > 0 do
    term.setCursorPos(1,1)
    write("Tries: "..tries)
    term.setCursorPos(13,9)
    write("Guess a number (1-100): ")
    input = tonumber(read())

    if input == nil then
        term.setCursorPos(16,7)
        write("Invalid Entry!")
    elseif input == number then
        term.setCursorPos(22,11)
        write("YOU WIN!!")
        sleep(2)
        term.clear()
        term.setCursorPos(1,1)
        break
    elseif input < number then
        term.clear()
        term.setCursorPos(10,6)
        write("The number is higher than "..input)
    elseif input > number then
        term.clear()
        term.setCursorPos(10,6)
        write("The number is lower than "..input)
    end
    
    if input ~= nil then
        tries = tries - 1
    end
end

if tries == 0 then
    term.setCursorPos(20,11)
    write("GAME OVER!")
    term.setCursorPos(16,12)
    write("The number was: "..number)
    sleep(2)
    term.clear()
    term.setCursorPos(1,1)
end
