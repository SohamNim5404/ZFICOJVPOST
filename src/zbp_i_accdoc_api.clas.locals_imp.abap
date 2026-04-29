CLASS lhc_zi_accdoc_api DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_accdoc_api RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_accdoc_api RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zi_accdoc_api.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_accdoc_api.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_accdoc_api.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_accdoc_api RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_accdoc_api.

ENDCLASS.

CLASS lhc_zi_accdoc_api IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
  DATA lt_db_ins TYPE STANDARD TABLE OF zfit_accdoc.

  LOOP AT entities ASSIGNING FIELD-SYMBOL(<e>).
  APPEND VALUE zfit_accdoc(
  docid   = <e>-Docid
      Bukrs   = <e>-bukrs
      Belnr   = <e>-belnr
      Gjahr   = <e>-gjahr
      Blart   = <e>-blart
      Bldat   = <e>-bldat
      Budat   = <e>-budat
      Waers   = <e>-waers
      Bupla   = <e>-bupla
      Secco   = <e>-secco
      Xblnr   = <e>-xblnr
      Bktxt   = <e>-bktxt
      Hkont   = <e>-hkont
      Dmbtr   = <e>-dmbtr
      Shkzg   = <e>-shkzg
      Kostl   = <e>-kostl
      Prctr   = <e>-prctr
      Mwskz   = <e>-mwskz
      Bank    = <e>-bank
      Hbkid   = <e>-hbkid
      Kunnr   = <e>-kunnr
      Lifnr   = <e>-lifnr
      Umskz   = <e>-umskz
      sgtxt   = <e>-sgtxt
      ZUONR   = <e>-ZUONR
      zlsch   = <e>-zlsch
      uname   = <e>-uname
  ) TO lt_db_ins.

  ENDLOOP.
  DATA(lt_zfit_accdoc) = lt_db_ins[].

  "Build unique Docids safely (avoids COLLECT/default-key issues and the stray '.wa_final' syntax error)
  DATA lt_docids TYPE SORTED TABLE OF zfit_accdoc-docid WITH UNIQUE KEY table_line.
  FIELD-SYMBOLS <ls_accdoc> TYPE zfit_accdoc.
  LOOP AT lt_zfit_accdoc ASSIGNING <ls_accdoc>.
    IF <ls_accdoc>-docid IS NOT INITIAL.
      INSERT <ls_accdoc>-docid INTO TABLE lt_docids.
    ENDIF.
  ENDLOOP.
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

    TYPES : BEGIN OF ty_msg,
              docid(10) TYPE c,
              belnr     TYPE belnr_d,
              msgty(1)  TYPE c,
              msg(200)  TYPE c,
            END OF ty_msg.
    DATA : it_msg    TYPE STANDARD TABLE OF ty_msg,
           wa_msg    TYPE ty_msg,
           lv_result TYPE string,
           lv_msg    TYPE c LENGTH 200.
    "Use the data coming from the request. The previous SELECT used an empty date range,
    "making it_doc empty and causing <fs_member> to be unassigned (GETWA_NOT_ASSIGNED).
    DATA it_doc TYPE STANDARD TABLE OF zfit_accdoc.
    it_doc = lt_zfit_accdoc.

    LOOP AT lt_docids ASSIGNING FIELD-SYMBOL(<lv_docid_key>).
       clear:ls_doc_h,lt_doc_h.
       CLEAR: ls_aritem, ls_apitem, ls_glitem, ls_glcurrency, ls_custcurrency, ls_vencurrency.
       CLEAR lv_buzei.
*      IF lv_docid <> <fs_doc>-docid.
        lv_docid = <lv_docid_key>.

        "Header row for the current document group (safe access; no field-symbol usage after loop)
        READ TABLE it_doc INTO DATA(ls_header) WITH KEY docid = <lv_docid_key>.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            %cid = <lv_docid_key>
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |No request data found for Docid { <lv_docid_key> }| ) )
            TO reported-zi_accdoc_api.
          CONTINUE.
        ENDIF.

        LOOP AT it_doc ASSIGNING FIELD-SYMBOL(<fs_member>) WHERE docid = <lv_docid_key>.

          lv_cid = <fs_member>-id.

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
*            ls_glitem-taxcountry = <fs_member>-taxcountry.ls_glitem-%control-taxcountry = if_abap_behv=>mk-on.
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
            ls_aritem-assignmentreference = <fs_member>-zuonr.ls_aritem-%control-assignmentreference = if_abap_behv=>mk-on.
            ls_aritem-documentitemtext = <fs_member>-sgtxt.ls_aritem-%control-documentitemtext = if_abap_behv=>mk-on.
            ls_aritem-taxcode          = <fs_member>-mwskz. ls_aritem-%control-taxcode  = if_abap_behv=>mk-on.
*            ls_aritem-taxcountry       = <fs_member>-taxcountry.ls_aritem-%control-taxcountry = if_abap_behv=>mk-on.
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
*            ls_apitem-taxcountry = <fs_member>-taxcountry.ls_apitem-%control-taxcountry = if_abap_behv=>mk-on.
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


        ls_doc_h-%cid = <lv_docid_key>.
        ls_doc_h-%param-companycode = ls_header-bukrs.
        ls_doc_h-%param-documentreferenceid = ls_header-xblnr.
        ls_doc_h-%param-createdbyuser = sy-uname.
        ls_doc_h-%param-businesstransactiontype = 'RFPI'.
        ls_doc_h-%param-accountingdocumenttype = ls_header-blart.

        "Expect OData V4 Edm.Date from the API: YYYY-MM-DD (will typically arrive as internal DATS already).
        DATA documentdate TYPE d.
        DATA postingdate  TYPE d.
        DATA lv_bldat     TYPE string.
        DATA lv_budat     TYPE string.

        lv_bldat = |{ ls_header-bldat }|.
        lv_budat = |{ ls_header-budat }|.
        REPLACE ALL OCCURRENCES OF '-' IN lv_bldat WITH ''.
        REPLACE ALL OCCURRENCES OF '-' IN lv_budat WITH ''.

        IF strlen( lv_bldat ) = 8 AND strlen( lv_budat ) = 8.
          documentdate = lv_bldat.
          postingdate  = lv_budat.
        ELSE.
          APPEND VALUE #(
            %cid = <lv_docid_key>
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |Invalid date format. Send Bldat/Budat as YYYY-MM-DD (e.g. 2025-12-26).| ) )
            TO reported-zi_accdoc_api.
          CONTINUE.
        ENDIF.

        ls_doc_h-%param-documentdate = documentdate.
        ls_doc_h-%param-postingdate = postingdate.
        ls_doc_h-%param-accountingdocumentheadertext = ls_header-bktxt.
        ls_doc_h-%param-taxdeterminationdate = documentdate.
        ls_doc_h-%param-taxreportingdate     = documentdate.
*            ls_doc_h-%param-


        ls_doc_h-%param-%control-companycode = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-documentreferenceid = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-createdbyuser = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-businesstransactiontype = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-accountingdocumenttype = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-documentdate = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-postingdate = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-accountingdocumentheadertext = if_abap_behv=>mk-on.
*            ls_doc_h-%param-%control-documentreferenceid = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-taxdeterminationdate = if_abap_behv=>mk-on.
        ls_doc_h-%param-%control-taxreportingdate = if_abap_behv=>mk-on.

        APPEND ls_doc_h TO lt_doc_h.

        IF lt_doc_h IS NOT INITIAL.

          "Action import call (no ENTITY ... here). Also: IN LOCAL MODE requires ENTITY,
          "so it cannot be used with this action-import-only EML form.
          "Call the released Journal Entry BO action. In this ADT release, PRIVILEGED requires ENTITY.
          "Use the bound-action EML form (ENTITY ... EXECUTE ...), and keep lt_doc_h typed for ACTION IMPORT.
          MODIFY ENTITIES OF i_journalentrytp PRIVILEGED
              ENTITY journalentry
              EXECUTE post FROM lt_doc_h
              FAILED DATA(ls_failed_deep)
              REPORTED DATA(ls_reported_deep)
              MAPPED DATA(ls_mapped_deep).


          IF ls_failed_deep IS NOT INITIAL.
            "Keep reporting simple and robust (type of ls_reported_deep depends on the released API).
            APPEND VALUE #(
              %cid = <lv_docid_key>
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = |Journal posting failed for Docid { <lv_docid_key> }. Check /IWBEP/ERROR_LOG and the Journal Entry messages.| ) )
              TO reported-zi_accdoc_api.
          ELSE.
            APPEND VALUE #(
              %cid = <lv_docid_key>
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-success
                       text     = |Journal posting triggered successfully for Docid { <lv_docid_key> }.| ) )
              TO reported-zi_accdoc_api.
*                COMMIT ENTITIES BEGIN
*                RESPONSE OF i_journalentrytp
*                FAILED DATA(lt_commit_failed)
*                REPORTED DATA(lt_commit_reported).
*
*
*                IF lt_commit_reported IS NOT INITIAL.
*                  LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_invoice>).
*                    IF <ls_invoice>-accountingdocument IS NOT INITIAL.
*                      "Success case
*                      CLEAR : wa_msg.
*                      wa_msg-belnr    = <ls_invoice>-accountingdocument.
*                      wa_msg-msgty    = 'S'.
*                      CONCATENATE  'Journal Posted Doc No. ' <ls_invoice>-accountingdocument INTO wa_msg-msg SEPARATED BY ''.
*                      APPEND wa_msg TO it_msg.
*                      CLEAR wa_msg.
*
*                      UPDATE zfit_accdoc SET belnr = @<ls_invoice>-accountingdocument,
*                                              gjahr = @<ls_invoice>-fiscalyear,
*                                              bukrs = @<ls_invoice>-companycode
*                                        WHERE docid = @<fs_member>-docid.
*                      COMMIT WORK.
*                    ELSE.
*
*                      "Error handling
*
*                      CLEAR : wa_msg.
*                      wa_msg-docid    = <fs_member>-docid.
*                      wa_msg-msgty    = 'E'.
*                      CONCATENATE 'Error hile Journal Entry' <fs_member>-docid
*                      INTO wa_msg-msg SEPARATED BY ''.
*                      APPEND wa_msg TO it_msg.
*                      CLEAR wa_msg.
*                    ENDIF.
*
*
*


          ENDIF.
*       zbp_i_accdoc_v2=>mapped_journalentrytp-journalentry =  ls_mapped_deep-journalentry.

        ENDIF.
*      ENDIF.
    ENDLOOP.

    IF sy-subrc = 0.
    LOOP AT entities ASSIGNING <e>.
      APPEND VALUE #(
        %cid = <e>-%cid
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-success
                 text     = |Created actionId { <e>-Docid }| ) )
        TO reported-zi_accdoc_api.
    ENDLOOP.
    endif.








  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_accdoc_api DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_accdoc_api IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
