alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

direction = input("Type 'encode' to encrypt, type 'decode' to decrypt:\n").lower()
text = input("Type your message:\n").lower()
shift = int(input("Type the shift number:\n"))


# TODO-1: Create a function called 'encrypt()' that takes 'original_text' and 'shift_amount' as 2 inputs.
# def encrypt():
#     letter_position=[]
#     shifted_position=[]
#     text_list=[]
#     shifted_text_list=[]
#     for letter in text:
#         letter_position.append(alphabet.index(letter))
#         shifted_position.append(alphabet.index(letter)+shift)
#     for position in letter_position:
#         print(alphabet[position])
#         text_list.append(alphabet[position])
#     for position in shifted_position:
#         print(alphabet[position])
#         shifted_text_list.append(alphabet[position])
#     plain_text=''.join(text_list)
#     shifted_text=''.join(shifted_text_list)
#     print(plain_text)
#     print(shifted_text)
#     print(letter_position)
#     print(shifted_position)
def encrypt(original_text, shift_amount):
    cipher_text=""
    for letter in original_text:
        shifted_position=alphabet.index(letter)+shift
        shifted_position %= len(alphabet)
        cipher_text+=alphabet[shifted_position]
    print(f"The original key is: {text}")
    print(f"Your cipher key is {cipher_text}")

# TODO-2: Inside the 'encrypt()' function, shift each letter of the 'original_text' forwards in the alphabet
#  by the shift amount and print the encrypted text.

# TODO-4: What happens if you try to shift z forwards by 9? Can you fix the code?

# TODO-3: Call the 'encrypt()' function and pass in the user inputs. You should be able to test the code and encrypt a
#  message.
encrypt(original_text=text,shift_amount=shift)