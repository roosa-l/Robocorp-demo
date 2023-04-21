*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           Collections
Variables         var.py

*** Variables ***
${ROBOT_NUMBER}    0


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    Log    ${orders}
    FOR    ${row}    IN    @{orders}
        ${ROBOT_NUMBER}=    Evaluate    ${ROBOT_NUMBER} + 1
        Close the modal
        Fill the form    ${row}
        Download and store the result    ${ROBOT_NUMBER}
        Order another robot
    END
    [Teardown]    Close RobotSpareBin Browsers

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
    [Arguments]    ${num}
    Click Element    preview
    Capture Element Screenshot    robot-preview-image   ${CURDIR}/robot.png
    Wait Until Keyword Succeeds
    ...    1 min    1 sec    Order robot and save receipt    ${num}


Order robot and save receipt
    [Arguments]    ${num}
    Click Element    order
        ${receipt_html}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${CURDIR}/receipt.pdf
    Add Watermark Image To Pdf    ${CURDIR}/robot.png
    ...                           ${CURDIR}/receiptwithimage-${num}.pdf    
    ...                           ${CURDIR}/receipt.pdf


Order another robot
    Click Element    order-another

Close RobotSpareBin Browsers
    Close All Browsers
