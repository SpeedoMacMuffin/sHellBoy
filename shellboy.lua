#!/usr/bin/env lua

local io = require("io")
local os = require("os")

-- Get the directory where the script is located
-- local function get_script_dir()
--     local str = debug.getinfo(2, "S").source:sub(2)
--     return str:match("(.*/)")
-- end

-- local SCRIPT_DIR = get_script_dir()

-- Specify the filename
local FILENAME = "ssh.txt"

-- Construct the full path to the file
local SERVER_FILE = FILENAME

-- Colors
local colors = {
    RED = "\27[0;31m",
    GREEN = "\27[0;32m",
    YELLOW = "\27[0;33m",
    MAGENTA = "\27[0;35m",
    CYAN = "\27[0;36m",
    NC = "\27[0m",
    BOLD = "\27[1m",
}

-- Function to display a fancy header
local function print_header()
    print(colors.CYAN .. colors.BOLD .. "=======================================")
    print("        sHellBoy Server Manager        ")
    print("=======================================" .. colors.NC)
end

local function print_help()
    print(colors.BOLD .. "Usage:" .. colors.NC .. " ./script.lua [options]")
    print()
    print(colors.BOLD .. "Options:" .. colors.NC)
    print("  -h, --help           Show this help message and exit")
    print()
    print(colors.BOLD .. "Interactive Options:" .. colors.NC)
    print("  Enter the number of the server to connect to that server")
    print("  a                    Add a new server")
    print("  u                    Update an existing server")
    print("  r                    Remove a server")
    print("  p                    Print the SSH command for a server")
    print("  q                    Quit the program")
end

local servers = {}
local usernames = {}
local pem_files = {}
local names = {}

-- Function to load the server list from the file
local function load_servers()
    local file = io.open(SERVER_FILE, "r")
    if file then
        for line in file:lines() do
            local name, server, username, pem_file = line:match("([^ ]+) ([^ ]+) ([^ ]+) (.*)")
            table.insert(names, name)
            table.insert(servers, server)
            table.insert(usernames, username)
            table.insert(pem_files, pem_file)
        end
        file:close()
    end
end

-- Function to save the server list to the file
local function save_servers()
    local file = io.open(SERVER_FILE, "w")
    for i = 1, #servers do
        file:write(string.format("%s %s %s %s\n", names[i], servers[i], usernames[i], pem_files[i]))
    end
    file:close()
end

-- Function to display the list of servers
local function display_servers()
    print(colors.YELLOW .. colors.BOLD .. "Please select a server to connect to:" .. colors.NC)
    for i = 1, #servers do
        print(
            colors.CYAN
            .. tostring(i - 1)
            .. ") "
            .. colors.GREEN
            .. names[i]
            .. colors.NC
            .. colors.CYAN
            .. " Host: "
            .. servers[i]
            .. " (Username: "
            .. usernames[i]
            .. ")"
            .. colors.NC
        )
    end
    print(colors.MAGENTA .. "a) Add a new server")
    print("u) Update a server")
    print("r) Remove a server")
    print("p) Print ssh-command")
    print("h) Print help")
    print("q) Exit the program" .. colors.NC)
end

-- Function to connect to the selected server
local function connect_to_server(index)
    index = tonumber(index) + 1
    if index >= 1 and index <= #servers then
        print(
            colors.YELLOW
            .. "Connecting to "
            .. colors.RED
            .. servers[index]
            .. colors.NC
            .. " as "
            .. usernames[index]
            .. "..."
        )
        local command
        if pem_files[index] ~= "" then
            command = string.format("ssh -i %s %s@%s", pem_files[index], usernames[index], servers[index])
        else
            command = string.format("ssh %s@%s", usernames[index], servers[index])
        end
        os.execute(command)
    else
        print(
            colors.RED
            .. "Invalid selection. Please enter a number between 0 and "
            .. tostring(#servers - 1)
            .. "."
            .. colors.NC
        )
    end
end

-- Function to add a new server
local function add_new_server()
    io.write("Enter the hostname or IP address of the new server: ")
    local new_server = io.read()
    io.write("Enter the username for the new server: ")
    local new_username = io.read()
    io.write("Enter the path to the PEM file (or leave empty if none): ")
    local new_pem = io.read()
    io.write("Enter a name for the connection: ")
    local new_name = io.read()
    if new_server ~= "" and new_username ~= "" then
        table.insert(servers, new_server)
        table.insert(usernames, new_username)
        table.insert(pem_files, new_pem)
        table.insert(names, new_name)
        print(colors.GREEN .. "Server '" .. new_name .. "' added successfully." .. colors.NC)
        save_servers()
    else
        print(colors.RED .. "Invalid input. Server not added." .. colors.NC)
    end
end

-- Function to remove a server
local function remove_server()
    print(colors.YELLOW .. "Please select a server to remove:" .. colors.NC)
    for i = 1, #servers do
        print(
            colors.CYAN .. tostring(i - 1) .. ") " .. servers[i] .. " (Username: " .. usernames[i] .. ")" .. colors.NC
        )
    end
    io.write("Enter the number of the server you wish to remove: ")
    local selection = tonumber(io.read())
    if selection and selection >= 0 and selection < #servers then
        print(colors.RED .. "Removing server " .. colors.GREEN .. servers[selection + 1] .. colors.NC .. "...")
        table.remove(servers, selection + 1)
        table.remove(usernames, selection + 1)
        table.remove(pem_files, selection + 1)
        table.remove(names, selection + 1)
        save_servers()
        print(colors.GREEN .. "Server removed successfully." .. colors.NC)
    else
        print(colors.RED .. "Invalid selection. Please enter a valid number." .. colors.NC)
    end
end

-- Function to update a server
local function update_server()
    print(colors.YELLOW .. "Please select a server to update:" .. colors.NC)
    for i = 1, #servers do
        print(
            colors.CYAN .. tostring(i - 1) .. ") " .. servers[i] .. " (Username: " .. usernames[i] .. ")" .. colors.NC
        )
    end
    io.write("Enter the number of the server you wish to update: ")
    local selection = tonumber(io.read())
    if selection and selection >= 0 and selection < #servers then
        print(colors.YELLOW .. "Which property would you like to update?" .. colors.NC)
        local properties = { "Name", "Host", "Username", "PEM-File" }
        for j = 1, #properties do
            print(colors.CYAN .. tostring(j - 1) .. ") " .. properties[j] .. colors.NC)
        end
        io.write("Enter the number of the property you want to change: ")
        local property = tonumber(io.read())
        if property and property >= 0 and property < #properties then
            io.write(
                "Change "
                .. properties[property + 1]
                .. " from "
                ..
                (property == 0 and names[selection + 1] or property == 1 and servers[selection + 1] or property == 2 and usernames[selection + 1] or pem_files[selection + 1])
                .. " to: "
            )
            local new_value = io.read()
            if property == 0 then
                names[selection + 1] = new_value
            elseif property == 1 then
                servers[selection + 1] = new_value
            elseif property == 2 then
                usernames[selection + 1] = new_value
            elseif property == 3 then
                pem_files[selection + 1] = new_value
            end
            save_servers()
            print(colors.GREEN .. "Server updated successfully." .. colors.NC)
        else
            print(colors.RED .. "Invalid input. Server not changed." .. colors.NC)
        end
    else
        print(colors.RED .. "Invalid selection. Please enter a valid number." .. colors.NC)
    end
end

-- Function to print the SSH command for a selected server
local function print_ssh_command()
    print(colors.YELLOW .. "Please select a server to print the SSH command:" .. colors.NC)
    for i = 1, #servers do
        print(
            colors.CYAN .. tostring(i - 1) .. ") " .. servers[i] .. " (Username: " .. usernames[i] .. ")" .. colors.NC
        )
    end
    io.write("Enter the number of the server you wish to print the SSH command for: ")
    local selection = tonumber(io.read())
    if selection and selection >= 0 and selection < #servers then
        if pem_files[selection + 1] ~= "" then
            print(
                colors.GREEN
                .. 'ssh -i "'
                .. pem_files[selection + 1]
                .. '" "'
                .. usernames[selection + 1]
                .. "@"
                .. servers[selection + 1]
                .. '"'
                .. colors.NC
            )
        else
            print(
                colors.GREEN .. 'ssh "' .. usernames[selection + 1] .. "@" .. servers[selection + 1] .. '"' .. colors.NC
            )
        end
    else
        print(colors.RED .. "Invalid selection. Please enter a valid number." .. colors.NC)
    end
end

-- Load the server list
load_servers()
print_header()

-- Main script logic
while true do
    display_servers()
    io.write("Enter an option: ")
    local selection = io.read()
    if tonumber(selection) then
        connect_to_server(selection)
        break
    elseif selection == "a" then
        add_new_server()
    elseif selection == "u" then
        update_server()
    elseif selection == "r" then
        remove_server()
    elseif selection == "p" then
        print_ssh_command()
    elseif selection == "h" then
        print_help()
    elseif selection == "q" then
        print(colors.GREEN .. "Goodbye" .. colors.NC)
        os.exit(0)
    else
        print(colors.RED .. "Invalid input. Please enter a valid option." .. colors.NC)
    end
end
