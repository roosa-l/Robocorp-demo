*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Variables         var.py

*** Variables ***
${orders}=    Get orders

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the modal
    Fill the form


*** Keywords ***
Open the robot order website
    Open Browser    ${URL}    chrome

Close the modal
    Click Element When Visible   ${ACCEPT_BTN}

Get orders
    Download    ${FILE_URL}     overwrite=${True}
    
Fill the form

