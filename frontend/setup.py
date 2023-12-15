from socket import gethostname, gethostbyname

#! Fill serverIpAddress dynamically in constants.dart file
with open('lib/constants.dart', 'r') as toRead:
    lines = toRead.readlines()
    ip_address = gethostbyname(gethostname())
    line_found = False
    for line in range(len(lines)):
        if 'serverIpAddress' in lines[line]:
            line_found = True
            value = lines[line].split('=')[-1]
            value = value[:2]+ip_address+value[len(value)-3:]
            new_line_value = lines[line].split('=')
            new_line_value[-1] = value
            new_line_value = '='.join(new_line_value)
            lines[line] = new_line_value
            with open('lib/constants.dart', 'w') as toWrite:
                toWrite.writelines(lines)
            break

    if not line_found:
        with open('lib/constants.dart', 'a') as toAdd:
            toAdd.write("\nString serverIpAddress = '"+ip_address+"';\n")

    print("-> Server IP IS SET TO "+ip_address+" !")
