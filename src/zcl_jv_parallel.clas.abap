CLASS zcl_jv_parallel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES tt_result TYPE STANDARD TABLE OF zfit_accdoc WITH EMPTY KEY.
    DATA: it_po_final  TYPE  tt_result,
          it_po_final1 TYPE  tt_result,
          it_log1       TYPE TABLE OF zins_log_grn,
          wa_log1       TYPE zins_log_grn.
    TYPES : BEGIN OF ty_msg,
              docid(10) TYPE c,
              belnr     TYPE belnr_d,
              msgty(1)  TYPE c,
              msg(200)  TYPE c,
            END OF ty_msg.
    DATA : it_msg TYPE STANDARD TABLE OF ty_msg,
           wa_msg TYPE ty_msg,
           it_log TYPE TABLE OF ztfi_jv_log,
           wa_log TYPE ztfi_jv_log.
    DATA : it_batch TYPE TABLE FOR CREATE i_batchtp_2,
           wa_batch LIKE LINE OF it_batch.
*           it_bitem TYPE TABLE FOR CREATE batchcharacteristic\_materialdocumentitem,
*           wa_bitem LIKE LINE OF it_batch.
    DATA : lv_posnr TYPE posnr.

    CLASS-DATA : it_po TYPE TABLE OF zmakS_excel_data,
                 wa_po TYPE zmakS_excel_data.
*                 it_result TYPE TABLE OF ty_result,
*                 wa_result TYPE ty_result.

    TYPES: BEGIN OF ty_keys1,
             sno TYPE c LENGTH 5,
           END OF  ty_keys1.

    DATA: lt_ser TYPE STANDARD TABLE OF ty_keys1,
          ls_ser TYPE ty_keys1.

    INTERFACES if_serializable_object .
    INTERFACES if_abap_parallel .

    METHODS constructor
      IMPORTING
        lt_po_details TYPE tt_result.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JV_PARALLEL IMPLEMENTATION.


     METHOD constructor.
    it_po_final = lt_po_details .
    it_po_final1 = lt_po_details .
  ENDMETHOD.


  METHOD if_abap_parallel~do.
    DATA: lt_doc_h        TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          lv_cid          TYPE abp_behv_cid,
          ls_doc_h        LIKE LINE OF lt_doc_h,
          ls_glitem       LIKE LINE OF ls_doc_h-%param-_glitems,
          ls_glcurrency   LIKE LINE OF ls_glitem-_currencyamount,
          ls_aritem       LIKE LINE OF ls_doc_h-%param-_aritems, "customer
          ls_taxitems     LIKE LINE OF ls_doc_h-%param-_taxitems,
          ls_custcurrency LIKE LINE OF ls_aritem-_currencyamount,
          ls_apitem       LIKE LINE OF ls_doc_h-%param-_apitems, "vendor
          ls_vencurrency  LIKE LINE OF ls_apitem-_currencyamount,
          lv_docid(10)    TYPE c,
          lv_buzei        TYPE i.
    DATA: wa_msg          TYPE ty_msg,
          it_log          TYPE TABLE OF ztfi_jv_log,
          wa_log          TYPE ztfi_jv_log.
    SORT it_po_final BY docid.
    DELETE ADJACENT DUPLICATES FROM it_po_final  COMPARING docid.
    LOOP AT it_po_final ASSIGNING FIELD-SYMBOL(<fs_doc>).
      CLEAR: ls_doc_h, lt_doc_h.
      CLEAR: ls_aritem, ls_apitem, ls_glitem, ls_glcurrency, ls_custcurrency, ls_vencurrency.
      lv_docid = <fs_doc>-docid.
      DATA(lv_item_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
      LOOP AT it_po_final1 ASSIGNING FIELD-SYMBOL(<fs_member>) WHERE docid = <fs_doc>-docid.
        IF <fs_member>-hkont IS NOT INITIAL.
          lv_buzei = lv_buzei + 1.
          ls_glitem-glaccountlineitem = lv_buzei.         ls_glitem-%control-glaccountlineitem = if_abap_behv=>mk-on.
          ls_glitem-glaccount         = <fs_member>-hkont.ls_glitem-%control-glaccount = if_abap_behv=>mk-on.
          ls_glitem-costcenter        = <fs_member>-kostl.ls_glitem-%control-costcenter = if_abap_behv=>mk-on.
          ls_glitem-profitcenter      = <fs_member>-prctr.ls_glitem-%control-profitcenter = if_abap_behv=>mk-on.
          ls_glitem-housebank = <fs_member>-bank.       ls_glitem-%control-housebank = if_abap_behv=>mk-on.
          ls_glitem-housebankaccount = <fs_member>-hbkid.   ls_glitem-%control-housebankaccount = if_abap_behv=>mk-on.
          ls_glitem-businessplace = <fs_member>-bupla.ls_glitem-%control-businessplace = if_abap_behv=>mk-on.
          ls_glitem-assignmentreference = <fs_member>-zuonr.ls_glitem-%control-assignmentreference = if_abap_behv=>mk-on.
          ls_glitem-documentitemtext = <fs_member>-sgtxt.ls_glitem-%control-documentitemtext = if_abap_behv=>mk-on.
          ls_glitem-taxcode = <fs_member>-mwskz.ls_glitem-%control-taxcode = if_abap_behv=>mk-on.
          ls_glitem-taxjurisdiction = ''.     ls_glitem-%control-taxjurisdiction = if_abap_behv=>mk-on.
          IF <fs_member>-shkzg = 'CR'. "CR = H
            ls_glcurrency-journalentryitemamount = <fs_member>-dmbtr * -1.
          ELSE.
            ls_glcurrency-journalentryitemamount = <fs_member>-dmbtr.
          ENDIF.
          ls_glcurrency-%control-journalentryitemamount = if_abap_behv=>mk-on.
          ls_glcurrency-currency = <fs_member>-waers.             ls_glcurrency-%control-currency = if_abap_behv=>mk-on.
          ls_glcurrency-currencyrole = '00'.                      ls_glcurrency-%control-currencyrole = if_abap_behv=>mk-on.
          ls_glitem-%control-_currencyamount = if_abap_behv=>mk-on.
          ls_doc_h-%param-%control-_glitems = if_abap_behv=>mk-on.
          APPEND ls_glcurrency TO ls_glitem-_currencyamount.
          APPEND ls_glitem TO ls_doc_h-%param-_glitems.
        ENDIF.
        IF <fs_member>-kunnr IS NOT INITIAL.
          lv_buzei = lv_buzei + 1.
          ls_aritem-glaccountlineitem = lv_buzei. ls_aritem-%control-glaccountlineitem = if_abap_behv=>mk-on.
          ls_aritem-customer = <fs_member>-kunnr. ls_aritem-%control-customer = if_abap_behv=>mk-on.
          ls_aritem-specialglcode     = <fs_member>-umskz.ls_aritem-%control-specialglcode = if_abap_behv=>mk-on.
          ls_aritem-businessplace = <fs_member>-bupla.ls_aritem-%control-businessplace = if_abap_behv=>mk-on.
*          ls_aritem-profitcenter      = <fs_member>-prctr.ls_aritem-%control-profitcenter = if_abap_behv=>mk-on.
          ls_aritem-assignmentreference = <fs_member>-zuonr.ls_aritem-%control-assignmentreference = if_abap_behv=>mk-on.
          ls_aritem-documentitemtext = <fs_member>-sgtxt.ls_aritem-%control-documentitemtext = if_abap_behv=>mk-on.
          ls_aritem-taxcode          = <fs_member>-mwskz. ls_aritem-%control-taxcode  = if_abap_behv=>mk-on.
          ls_aritem-taxjurisdiction = ''.ls_aritem-%control-taxjurisdiction = if_abap_behv=>mk-on.
          IF <fs_member>-shkzg = 'CR'. "CR = H
            ls_custcurrency-journalentryitemamount = <fs_member>-dmbtr * -1.
          ELSE.
            ls_custcurrency-journalentryitemamount = <fs_member>-dmbtr.
          ENDIF.
          ls_custcurrency-%control-journalentryitemamount = if_abap_behv=>mk-on.
          ls_custcurrency-currency = <fs_member>-waers.ls_custcurrency-%control-currency = if_abap_behv=>mk-on.
          ls_custcurrency-currencyrole = '00'.         ls_custcurrency-%control-currencyrole = if_abap_behv=>mk-on.
          ls_aritem-%control-_currencyamount = if_abap_behv=>mk-on.
          ls_doc_h-%param-%control-_aritems = if_abap_behv=>mk-on.
          APPEND ls_custcurrency TO ls_aritem-_currencyamount.
          APPEND ls_aritem TO ls_doc_h-%param-_aritems.
        ENDIF.
        IF <fs_member>-lifnr IS NOT INITIAL.
          lv_buzei = lv_buzei + 1.
          ls_apitem-glaccountlineitem = lv_buzei. ls_apitem-%control-glaccountlineitem = if_abap_behv=>mk-on.
          ls_apitem-supplier = <fs_member>-lifnr. ls_apitem-%control-supplier = if_abap_behv=>mk-on.
          ls_apitem-specialglcode = <fs_member>-umskz. ls_apitem-%control-specialglcode = if_abap_behv=>mk-on.
          ls_apitem-businessplace = <fs_member>-bupla.ls_apitem-%control-businessplace = if_abap_behv=>mk-on.
          ls_apitem-assignmentreference = <fs_member>-zuonr.ls_apitem-%control-assignmentreference = if_abap_behv=>mk-on.
          ls_apitem-documentitemtext = <fs_member>-sgtxt.ls_apitem-%control-documentitemtext = if_abap_behv=>mk-on.
          ls_apitem-paymentmethod = <fs_member>-zlsch.ls_apitem-%control-paymentmethod = if_abap_behv=>mk-on.
          ls_apitem-taxcode =  <fs_member>-mwskz. ls_apitem-%control-taxcode = if_abap_behv=>mk-on.
          ls_apitem-taxjurisdiction = ''.ls_apitem-%control-taxjurisdiction = if_abap_behv=>mk-on.
          IF <fs_member>-shkzg = 'CR'. "CR = H
            ls_vencurrency-journalentryitemamount = <fs_member>-dmbtr * -1.
          ELSE.
            ls_vencurrency-journalentryitemamount = <fs_member>-dmbtr.
          ENDIF.
          ls_vencurrency-%control-journalentryitemamount = if_abap_behv=>mk-on.
          ls_vencurrency-currency = <fs_member>-waers.  ls_vencurrency-%control-currency = if_abap_behv=>mk-on.
          ls_apitem-%control-_currencyamount = if_abap_behv=>mk-on.
          ls_doc_h-%param-%control-_apitems = if_abap_behv=>mk-on.
          APPEND ls_vencurrency TO ls_apitem-_currencyamount.
          APPEND ls_apitem TO ls_doc_h-%param-_apitems.
        ENDIF.
        CLEAR: ls_aritem, ls_apitem, ls_glitem, ls_glcurrency, ls_custcurrency, ls_vencurrency.
      ENDLOOP.
      ls_doc_h-%cid = <fs_doc>-docid.
      ls_doc_h-%param-companycode = <fs_member>-bukrs.
      ls_doc_h-%param-documentreferenceid = <fs_member>-xblnr.
      ls_doc_h-%param-createdbyuser = sy-uname.
      ls_doc_h-%param-businesstransactiontype = 'RFPI'.
      ls_doc_h-%param-accountingdocumenttype = <fs_member>-blart.

      DATA: documentdate TYPE budat,
            postingdate  TYPE budat.
      CONCATENATE: <fs_member>-bldat+6(4) <fs_member>-bldat+3(2) <fs_member>-bldat+0(2) INTO documentdate,
                   <fs_member>-budat+6(4) <fs_member>-budat+3(2) <fs_member>-budat+0(2) INTO postingdate.
      ls_doc_h-%param-documentdate = documentdate.
      ls_doc_h-%param-postingdate = postingdate.
      ls_doc_h-%param-accountingdocumentheadertext = <fs_member>-bktxt.
      ls_doc_h-%param-taxdeterminationdate = documentdate.
      ls_doc_h-%param-taxreportingdate     = documentdate.
      ls_doc_h-%param-%control-companycode = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-documentreferenceid = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-createdbyuser = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-businesstransactiontype = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-accountingdocumenttype = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-documentdate = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-postingdate = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-accountingdocumentheadertext = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-taxdeterminationdate = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-taxreportingdate = if_abap_behv=>mk-on.
      APPEND ls_doc_h TO lt_doc_h.
      IF lt_doc_h IS NOT INITIAL.
        MODIFY ENTITIES OF i_journalentrytp
            ENTITY journalentry
            EXECUTE post FROM lt_doc_h
            FAILED FINAL(ls_failed_deep)
            REPORTED FINAL(ls_reported_deep)
            MAPPED FINAL(ls_mapped_deep).
        "------------------------------------------------------------------
        " 1. Capture Execute Validation Errors
        "------------------------------------------------------------------
        IF ls_failed_deep IS NOT INITIAL.
            DATA(lv_error_found) = abap_false.

            " Check Entity-specific errors
            LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_report>).
                IF <ls_report>-%msg IS BOUND.
                    CLEAR wa_msg.
                    wa_msg-docid = <fs_doc>-docid.
                    wa_msg-msgty = 'E'.
                    wa_msg-msg   = <ls_report>-%msg->if_message~get_text( ).
                    APPEND wa_msg TO it_msg.
                    lv_error_found = abap_true.
                ENDIF.
            ENDLOOP.
            " Check global/%other errors
            LOOP AT ls_reported_deep-%other ASSIGNING FIELD-SYMBOL(<lo_other>).
                IF <lo_other> IS BOUND.
                    CLEAR wa_msg.
                    wa_msg-docid = <fs_doc>-docid.
                    wa_msg-msgty = 'E'.
                    wa_msg-msg   = |Error { <fs_doc>-docid }: { <lo_other>->if_message~get_text( ) }|.
                    APPEND wa_msg TO it_msg.
                    lv_error_found = abap_true.
                ENDIF.
            ENDLOOP.
            " Fallback Error
            IF lv_error_found = abap_false.
                CLEAR wa_msg.
                wa_msg-docid = <fs_doc>-docid.
                wa_msg-msgty = 'E'.
                wa_msg-msg   = |Validation Failed for Doc { <fs_doc>-docid } - Check Input Data|.
                APPEND wa_msg TO it_msg.
            ENDIF.
        ELSE.
            "------------------------------------------------------------------
            " 2. Capture Commit Execution Errors & Success
            "------------------------------------------------------------------
            COMMIT ENTITIES BEGIN
            RESPONSE OF i_journalentrytp
            FAILED DATA(lt_commit_failed)
            REPORTED DATA(lt_commit_reported).
            IF lt_commit_reported IS NOT INITIAL.
              " A. Loop over Journal Entries for Success and specific errors
              LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_invoice>).
                wa_log-docid   = <fs_doc>-docid.
                wa_log-lifnr   = <fs_doc>-lifnr.
                wa_log-kostl   = <fs_doc>-kostl.
                IF <ls_invoice>-accountingdocument IS NOT INITIAL.
                  " SUCCESS MESSAGE
                  CLEAR wa_msg.
                  wa_msg-belnr = <ls_invoice>-accountingdocument.
                  wa_msg-msgty = 'S'.
                  wa_msg-msg   = |Journal Posted Doc No. { <ls_invoice>-accountingdocument } for { <fs_doc>-docid }|.
                  APPEND wa_msg TO it_msg.
                  wa_log-belnr = <ls_invoice>-accountingdocument.
                  wa_log-bukrs = <ls_invoice>-companycode.
                  wa_log-gjahr = <ls_invoice>-fiscalyear.
                  UPDATE zfit_accdoc SET belnr = @<ls_invoice>-accountingdocument,
                                          gjahr = @<ls_invoice>-fiscalyear,
                                          bukrs = @<ls_invoice>-companycode
                                    WHERE docid = @<fs_doc>-docid.
                  COMMIT WORK.
                ELSE.
                  " ERROR MESSAGE (during commit)
                  IF <ls_invoice>-%msg IS BOUND.
                    DATA(lv_text) = <ls_invoice>-%msg->if_message~get_text( ).
                    wa_log-mess = lv_text.

                    CLEAR wa_msg.
                    wa_msg-docid = <fs_doc>-docid.
                    wa_msg-msgty = 'E'.
                    wa_msg-msg   = |Commit Error Doc { <fs_doc>-docid } : { lv_text }|.
                    APPEND wa_msg TO it_msg.
                  ENDIF.
                ENDIF.

                wa_log-zid = lv_item_uuid.
                MODIFY ztfi_jv_log FROM @wa_log.
                COMMIT WORK.
                CLEAR wa_log.
              ENDLOOP.

              " B. Loop over global/%OTHER commit errors
              LOOP AT lt_commit_reported-%other ASSIGNING FIELD-SYMBOL(<lo_commit_oth>).
                IF <lo_commit_oth> IS BOUND.
                    CLEAR wa_msg.
                    wa_msg-docid = <fs_doc>-docid.
                    wa_msg-msgty = 'E'.
                    wa_msg-msg   = |Commit Error { <fs_doc>-docid }: { <lo_commit_oth>->if_message~get_text( ) }|.
                    APPEND wa_msg TO it_msg.
                ENDIF.
              ENDLOOP.
            ENDIF.

            " Fallback if Commit Failed but no message was given
            IF lt_commit_failed IS NOT INITIAL AND lt_commit_reported IS INITIAL.
                CLEAR wa_msg.
                wa_msg-docid = <fs_doc>-docid.
                wa_msg-msgty = 'E'.
                wa_msg-msg   = |Commit Execution Failed for { <fs_doc>-docid }|.
                APPEND wa_msg TO it_msg.
            ENDIF.
            COMMIT ENTITIES END.
        ENDIF.

        " Map mapped values correctly
        IF ls_mapped_deep IS NOT INITIAL.
          zbp_i_accdoc_v2=>mapped_journalentrytp-journalentry = ls_mapped_deep-journalentry.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
