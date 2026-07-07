#TODO: Create a letter using starting_letter.txt 
#for each name in invited_names.txt
#Replace the [name] placeholder with the actual name.
#Save the letters in the folder "ReadyToSend".

#Hint1: This method will help you: https://www.w3schools.com/python/ref_file_readlines.asp
    #Hint2: This method will also help you: https://www.w3schools.com/python/ref_string_replace.asp
        #Hint3: THis method will help you: https://www.w3schools.com/python/ref_string_strip.asp


#Here names
with open("Mail merging/Input/Names/invited_names.txt") as names:
    names = names.readlines()


    with open ("Mail merging/Input/Letters/starting_letter.txt") as letters:
        letter = letters.read()
        
        for name in names:
            striped_names = name.strip("\n")
            new_letter = letter.replace("[name]", striped_names)
            with open(f"Mail merging/Output/ReadyToSend/invite_for_{striped_names}.txt", mode="w") as invite:
                invite.write(new_letter)