function saveAccount(user, pass)
    local file = fs.open(user..".txt","w")
    file.write(pass)
    file.close()
end

function loadAccount(user)
    if not fs.exists(user..".txt") then
        return nil
    end
    local file = fs.open(user..".txt", "r")
    local password = file.readAll()
    file.close()
    return password
end

function listUsers()
    term.clear()
    local files = fs.list("/")
    print("Registered Accounts:")
    for _, file in ipairs(files) do
        if file:match("%.txt$") and file ~= "admin.txt" then
            print(" - ".. file:gsub("%.txt$", ""))
        end
    end
    print("\nPress any key to return!")
    os.pullEvent("key")
end

function changePassword()
    term.clear()
    write("Enter username to modify: ")
    local user = read()

    if not fs.exists(user..".txt") then
        print("User not found!")
        sleep(2)
        return
    end

    write("New Password: ")
    local newPass = read("*")
    write("Confirm Password: ")
    local newPassConfirm = read("*")

    if newPass == newPassConfirm then
        local file = fs.open(user..".txt", "w")
        file.write(newPass)
        file.close()

        print("Password updated!")
        sleep(2)
    else
        print("Passwords do not match!")
        sleep(2)
        return
    end
end

function deleteAccount()
    term.clear()
    write("Enter username you with to delete: ")
    local user = read()

    if not fs.exists(user..".txt") then
        print("User not found!")
        sleep(2)
        return
    end

    fs.delete(user..".txt")
    print("Account deleted!")
    sleep(2)
end

function isAdmin(user)
    if not fs.exists("admin.txt") then return false end

    local file = fs.open("admin.txt","r")
    local adminUser = file.readLine()
    file.close()

    return user == adminUser
end

function login()
    term.clear()
    term.setCursorPos(1,1)
    write("Username: ")
    local user = read()
    write("Password: ")
    local pass = read("*")

    local storedPassword = loadAccount(user)

    if storedPassword == nil then
        print("Account does not exist!")
    elseif storedPassword == pass then
        if isAdmin(user) then
            adminDashboard()
        else
            print("Login successful! Welcome, "..user)
            sleep(2)
            userDashboard(user)
        end
    else
        print("Incorrect password!")
    end

    sleep(2)
    return false
end

function isFirstAccount()
    local files = fs.list("/")
    local count = 0

    for _, file in ipairs(files) do
        if file:match("%.txt$") and file ~= "admin.txt" then
            count = count + 1
        end
    end

    return count == 0
end

function register()
    term.clear()
    term.setCursorPos(1,1)
    write("Enter a username: ")
    local user = read()

    if fs.exists(user..".txt") then
        print("That account already exists!")
        sleep(2)
        return
    end
    
    local first = isFirstAccount()

    write("Enter password: ")
    local pass = read("*")
    
    if pass == nil or #pass < 5 or user == nil or #user < 3 then
        print("Username must be at least 3 characters!")
        print("Password must be at least 5 characters!")
        sleep(3)
    else
        saveAccount(user, pass)
        print("Account created successfully!")
        if first then
            local file = fs.open("admin.txt","w")
            file.writeLine(user)
            file.close()
            print("User: "..user.." has been set as admin!")
        end
        sleep(2)
    end
end

function navigate(options, actions)
    local selected = 1

    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("==SELECT AN OPTION!==")

        for i, option in ipairs(options) do
            if i == selected then
                print(" > ".. option)
            else
                print("   ".. option)
            end
        end

        local event, key = os.pullEvent("key")
        if key == keys.w then
            selected = selected - 1
            if selected < 1 then selected = #options end
        elseif key == keys.s then
            selected = selected + 1
            if selected > #options then selected = 1 end
        elseif key == keys.enter then
            local action = actions[selected]
            if action then
                local shouldExit = action()
                if shouldExit then return end
            end
        end
    end
end

function adminDashboard() --Admin Menu
    local options = {"View All Users", "Change User Password", "Delete Account", "Logout"}

    local actions = {
        function() listUsers() end,
        function() changePassword() end,
        function() deleteAccount() end,
        function() return true end --LOGOUT
    }

    navigate(options, actions)
end

function notesMenu(user)
    local notesFile = user..".note"

    local options = {
        "View Notes",
        "Add Note",
        "Clear Notes",
        "Back"
    }

    local actions = {
        function()
            term.clear()
            if fs.exists(notesFile) then
                local file = fs.open(notesFile, "r")
                local content = file.readAll()
                file.close()
                print("Your notes:\n")
                print(content)
            else
                print("No notes found!")
            end
            print("\nPress any key to continue!")
            os.pullEvent("key")
        end,

        function()
            term.clear()
            write("Enter a new note: ")
            local note = read()
            if #note > 0 then
                local file = fs.open(notesFile, "a") --Append
                file.writeLine(note)
                file.close()
                print("Note added!")
            else
                print("Empty note discarded!")
            end
            sleep(2)
        end,

        function()
            if fs.exists(notesFile) then
                fs.delete(notesFile)
                print("All notes have been cleared!")
            else
                print("No notes exist!")
            end
            sleep(2)
        end,

        function() --Back
            return true
        end
    }

    navigate(options, actions)
end

function userDashboard(user) --User Menu
    local options = {
        "Change Password",
        "My Notes",
        "Logout"
    }

    local actions = {
        function()
            term.clear()
            write("Enter new password: ")
            local newPass = read("*")
            write("Confirm password: ")
            local confirmPass = read("*")

            if newPass == confirmPass and #newPass >= 5 then
                local file = fs.open(user..".txt", "w")
                file.write(newPass)
                file.close()
                print("The password has been updated!")
            else
                print("Password did not match OR were too short.")
            end
            sleep(2)
        end,

        function()
            notesMenu(user)
        end,

        function()
            return true --Logout
        end
    }

    navigate(options, actions)
end

function menu() -- Default Menu
    local options = {"Login", "Register", "Quit"}

    local actions = {
        function()
            if login() then return true end
        end,
        function()
            register()
        end,
        function()
            return true --QUIT
        end
    }

    navigate(options, actions)
end

menu()
