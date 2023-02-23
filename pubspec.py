import sys

identity = sys.argv[1]
publisher = sys.argv[2]

with open('pubspec.yaml', 'r') as file:
  contents = file.read()

contents = contents.replace('{{IDENTITY}}', identity)
contents = contents.replace('{{PUBLISHER}}', publisher)

with open('pubspec.yaml', 'w') as file:
  file.write(contents)
