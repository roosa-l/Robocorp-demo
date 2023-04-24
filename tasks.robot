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
Library    RPA.Archive
Library    OperatingSystem


*** Variables ***
${ORDER_URL}     https://robotsparebinindustries.com/#/robot-order
${ACCEPT_BTN}    //button[contains(@class, "btn-dark")]
${FILE_URL}      https://robotsparebinindustries.com/orders.csv
${LEGS_FIELD}    //input[@class="form-control"][@type="number"]



*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}    
        Close the annoying modal
        Fill the form    ${row}
        Preview and order the robot
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Order another robot
    END
    Archive receipts into a ZIP file
    [Teardown]    Close browser and delete unnecessary directories


*** Keywords ***
Open the robot order website
    Open Available Browser    ${ORDER_URL}

Close the annoying modal
    Click Element When Visible   ${ACCEPT_BTN}

Get orders
    Download    ${FILE_URL}     overwrite=True
    ${table}=    Read table from CSV    orders.csv
    ${rows}  ${columns}=    Get Table Dimensions    ${table}
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
    Input Text    ${LEGS_FIELD}    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview and order the robot
    Click Element    preview
    Wait Until Keyword Succeeds    1 min    1 sec    Order robot

Order robot
    Click Element    order
    Element Should Be Visible    receipt

Store the receipt as a PDF file
    [Arguments]    ${order}
    ${receipt_html}=    Get Element Attribute    receipt    outerHTML
    ${path}=    Set Variable    ${OUTPUT_DIR}${/}receipts${/}receipt-${order}.pdf
    Html To Pdf    ${receipt_html}    ${path}
    RETURN    ${path}

Take a screenshot of the robot
    [Arguments]    ${order}
    ${path}=    Set Variable    ${OUTPUT_DIR}${/}robots${/}robot-${order}.png
    Capture Element Screenshot    robot-preview-image    ${path}
    RETURN    ${path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}    ${pdf}

Order another robot
    Click Element    order-another

Archive receipts into a ZIP file
    ${zip_file}=    Set Variable    ${OUTPUT_DIR}${/}receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${zip_file}

Close browser and delete unnecessary directories
    Close All Browsers
    Remove Directory    ${OUTPUT_DIR}/receipts    recursive=True
    Remove Directory    ${OUTPUT_DIR}/robots    recursive=True