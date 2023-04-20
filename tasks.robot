*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
Library           Collections
Variables         var.py


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    Log    ${orders}
    FOR    ${row}    IN    @{orders}
        Close the modal
        Fill the form    ${row}
        Download and store the result
        #Order another robot
    END
    #[Teardown]    Close RobotSpareBin Browsers

*** Keywords ***
Open the robot order website
    Open Available Browser    ${URL}

Close the modal
    Click Element When Visible   ${ACCEPT_BTN}

Get orders
    Download    ${FILE_URL}     overwrite=True
    ${table}=    Read table from CSV    orders.csv
    ${dim}=    Get Table Dimensions    ${table}
    ${rows}=     Set Variable   ${dim}[0]
    @{orders}=    Create List    
    FOR    ${index}    IN RANGE    0    ${rows} 
        ${row}=    Get Table Row    ${table}    ${index}
        Append To List    ${orders}    ${row}
    END
    RETURN    ${orders}

Fill the form
    [Arguments]    ${row}
    Select From List By Value   head    ${row}[Head]
    Click Element    id-body-${row}[Body]
    Input Text    //input[@class="form-control"][@type="number"]    ${row}[Legs]
    Input Text    address    ${row}[Address]

Download and store the result
    Click Element    preview
    Capture Element Screenshot    robot-preview-image   robot.png


Close RobotSpareBin Browsers