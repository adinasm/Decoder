## Task 1:
- decodes a string encoded by xoring a string with a key that has the same
  size as the string;
- xors every byte from the string with the byte from the key that's situated
  on the same position (encoded_string ^ key = decoded_string, where
  encoded_string = decoded_string ^ key);
- the decoded string overwrites the encoded one.

## Task 2:
- decodes a string encoded by xoring the i-th byte with the i-1-th byte,
  (i = 1, string_length);
- in order to decode it, the string has to be examined from the end,
  xoring the i-th byte with the i-1-th byte (i = string_length, 1);
- the decoded string overwrites the encoded one.

## Task 3:
- decodes a string encoded by xoring a string with a key that has the same
  size as the string;
- the string and the key are represented in hex;
- the conversion from hex to byte is done in the following way:
  the corresponding values from the 2*i-th byte and the 2*i+1-th byte are
  calculated and the result is stored in the i-th byte of the string;
- xors every byte from the string with the byte from the key that's situated
  on the same position (encoded_string ^ key = decoded_string, where
  encoded_string = decoded_string ^ key);
- the decoded string overwrites the encoded one.

## Task 4:
- decodes a base32 encoded string;
- 8 bytes(values) from the encoded string are processed at once;
- for every encoded value, the decoded one is computed using the convert_byte
  function;
- each part of every decoded value is placed accordingly in the 5 generated
  bytes of the decoded string;
- the decoded string overwrites the encoded one.

## Task 5:
- decodes a string encoded by xoring every byte from a string with a one byte
  key;
- computes every one byte key (numbers from 0 to 255);
- for every generated key, the decoded string is generated and if the string
  contains the substring "force", then the key has been found, otherwise the
  xor operation is undone;
- the decoded string overwrites the encoded one;
- the key is returned in the eax register.

## Task 6:
- decodes a string encoded using the Vigenere Cipher;
- for every byte from the encoded string (only the alphabetical characters),
  the offset from the letter "a" given by the corresponding byte from the key
  is calculated;
- the letter is shifted left (ex: byte_from_key = d, encoded_byte = c,
  decoded_byte = z) with the calculated offset;
- the decoded string overwrites the encoded one.
