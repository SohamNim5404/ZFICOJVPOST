CLASS zbp_i_accdoc_v2 DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_accdoc_v2.
pUBLIC SECTION.
    CLASS-DATA mapped_journalentrytp TYPE RESPONSE FOR MAPPED i_journalentrytp.

    CLASS-DATA : lt_Journal  type table of zfit_accdoc,
                 lt_Dtl      type table of zfit_accdoc.

protected section.
private section.
ENDCLASS.



CLASS ZBP_I_ACCDOC_V2 IMPLEMENTATION.
ENDCLASS.
