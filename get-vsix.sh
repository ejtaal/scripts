#!/usr/bin/env python

# Code from: https://stackoverflow.com/questions/79359919/how-can-i-download-vsix-files-now-that-the-visual-studio-code-marketplace-no-lo


unique_identifier = 'ms-python.python'
version = '2024.17.2024100401'
target_platform = 'win32-x64'

publisher, package = unique_identifier.split('.')
url = (
    f'https://marketplace.visualstudio.com/_apis/public/gallery/publishers/{publisher}/vsextensions/{package}/{version}/vspackage'
    + (f'?targetPlatform={target_platform}' if target_platform else ''))
print(url)
