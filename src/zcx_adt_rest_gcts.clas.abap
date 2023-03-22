class ZCX_ADT_REST_GCTS definition
  public
  inheriting from CX_ADT_REST
  final
  create public .

public section.

  interfaces IF_T100_DYN_MSG .

  class-methods RAISE_WITH_ERROR
    importing
      !IX_ERROR type ref to CX_ROOT
      !IV_HTTP_STATUS type I optional
    raising
      ZCX_ADT_REST_ABAPGIT .
  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !SUBTYPE type SADT_EXC_TYPE optional
      !MSGV1 type SYMSGV optional
      !MSGV2 type SYMSGV optional
      !MSGV3 type SYMSGV optional
      !MSGV4 type SYMSGV optional
      !PROPERTIES type ref to IF_ADT_EXCEPTION_PROPERTIES optional .

  methods GET_HTTP_STATUS
    redefinition .
  methods GET_NAMESPACE
    redefinition .
  methods GET_TYPE
    redefinition .
protected section.
  PRIVATE SECTION.

    DATA mv_http_status TYPE i.

    CLASS-METHODS get_message_var
      IMPORTING
        ix_error          TYPE REF TO cx_root
        iv_attribute      TYPE csequence
      RETURNING
        VALUE(rv_msg_var) TYPE symsgv.

ENDCLASS.



CLASS ZCX_ADT_REST_GCTS IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
SUBTYPE = SUBTYPE
MSGV1 = MSGV1
MSGV2 = MSGV2
MSGV3 = MSGV3
MSGV4 = MSGV4
PROPERTIES = PROPERTIES
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD GET_HTTP_STATUS.

    IF mv_http_status IS INITIAL.
      result = cl_rest_status_code=>gc_client_error_bad_request.
    ELSE.
      result = mv_http_status.
    ENDIF.

  ENDMETHOD.


  METHOD GET_MESSAGE_VAR.

    IF iv_attribute IS NOT INITIAL.
      ASSIGN ix_error->(iv_attribute) TO FIELD-SYMBOL(<lv_msg_var>).
      rv_msg_var = <lv_msg_var>.
    ENDIF.

  ENDMETHOD.


  METHOD GET_NAMESPACE.

    result = 'org.abapgit.adt'.

  ENDMETHOD.


  METHOD GET_TYPE ##needed.
  ENDMETHOD.


  METHOD RAISE_WITH_ERROR.

    DATA lx_error        TYPE REF TO cx_root.
    DATA lo_message      TYPE REF TO if_t100_message.
    DATA lo_next_message TYPE REF TO if_t100_message.

    lx_error = ix_error.
    lo_message ?= ix_error.

    WHILE lx_error->previous IS BOUND.

      TRY.
          lo_next_message ?= lx_error->previous.
          lo_message = lo_next_message.
          lx_error = lx_error->previous.
        CATCH cx_sy_move_cast_error.
          EXIT.
      ENDTRY.

    ENDWHILE.

    DATA(ls_msg_key) = lo_message->t100key.

    DATA(lv_msgv1) = get_message_var(
      ix_error     = lx_error
      iv_attribute = ls_msg_key-attr1 ).
    DATA(lv_msgv2) = get_message_var(
      ix_error     = lx_error
      iv_attribute = ls_msg_key-attr2 ).
    DATA(lv_msgv3) = get_message_var(
      ix_error     = lx_error
      iv_attribute = ls_msg_key-attr3 ).
    DATA(lv_msgv4) = get_message_var(
      ix_error     = lx_error
      iv_attribute = ls_msg_key-attr4 ).

    RAISE EXCEPTION TYPE zcx_adt_rest_abapgit
      MESSAGE
      ID ls_msg_key-msgid
      TYPE 'E'
      NUMBER ls_msg_key-msgno
      WITH lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4
      EXPORTING
        iv_http_status = iv_http_status.

  ENDMETHOD.
ENDCLASS.
