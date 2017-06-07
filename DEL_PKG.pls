create or replace PACKAGE DEL_PKG AS 

  procedure create_delegation(
    p_dde_id out DEL_DELEGATIONS.DDE_ID%TYPE,
    p_dve_id in DEL_DELEGATIONS.DVE_ID%TYPE,
    p_dde_created_by in DEL_DELEGATIONS.DDE_CREATED_BY%TYPE,
    p_dde_approver in DEL_DELEGATIONS.DDE_APPROVER%TYPE,
    p_dde_oper_now_role in DEL_DELEGATIONS.DDE_OPER_NOW_ROLE%TYPE
  ); 
  
  procedure approve_delegation(
  p_dde_id in DEL_DELEGATIONS.DDE_ID%TYPE,
  p_dde_approved_by in DEL_DELEGATIONS.DDE_APPROVED_BY%TYPE,
  p_ddn_year in varchar2 default null
   );
  
   procedure reject_delegation(
  p_dde_id in DEL_DELEGATIONS.DDE_ID%TYPE,
  p_dde_approved_by in DEL_DELEGATIONS.DDE_APPROVED_BY%TYPE
   ); 
   
  procedure create_proposition(
   p_dpr_id out DEL_PROPOSITIONS.DPR_ID%TYPE,
   p_dde_id in DEL_PROPOSITIONS.DDE_ID%TYPE,
   p_dpr_created_by in DEL_PROPOSITIONS.DPR_CREATED_BY%TYPE,
   p_dpr_destination in DEL_PROPOSITIONS.DPR_DESTINATION%TYPE,
   p_dpr_date_from in DEL_PROPOSITIONS.DPR_DATE_FROM%TYPE,
   p_dpr_date_to in DEL_PROPOSITIONS.DPR_DATE_TO%TYPE,
   p_dtt_ids in DEL_PROPOSITIONS.DTT_IDS%TYPE,
   p_dpr_purpose in DEL_PROPOSITIONS.DPR_PURPOSE%TYPE
  );
  
  procedure create_question(
      p_dqu_id out DEL_QUESTIONS.DQU_ID%TYPE,
      p_dpr_id in DEL_QUESTIONS.DPR_ID%TYPE,
      p_dde_id in DEL_QUESTIONS.DDE_ID%TYPE,
      p_created_by in DEL_QUESTIONS.DQU_CREATED_BY%TYPE,
      p_dqu_recipient_role in DEL_QUESTIONS.DQU_RECIPIENT_ROLE%TYPE,
      p_dqu_recipient in DEL_QUESTIONS.DQU_RECIPIENT%TYPE,
      p_dqu_question in DEL_QUESTIONS.DQU_QUESTION%TYPE,
      p_dqu_printable in DEL_QUESTIONS.DQU_PRINTABLE%TYPE
  );
  
   procedure answer_question(
      p_dqu_id in DEL_QUESTIONS.DQU_ID%TYPE,
      p_dqu_answer in DEL_QUESTIONS.DQU_ANSWER%TYPE,
      p_dqu_answered_by in DEL_QUESTIONS.DQU_ANSWERED_BY%TYPE
  );
  
   procedure delete_question(
        p_dqu_id in number,
        p_dqu_deleted_by in number
    );
    
    procedure create_notice(
        p_dno_id	out	DEL_NOTICES.DNO_ID%type,
        p_dpr_id	in	DEL_NOTICES.DPR_ID%type	default null	,
        p_dde_id	in	DEL_NOTICES.DDE_ID%type	default null	,
        p_dno_created_by	in	DEL_NOTICES.DNO_CREATED_BY%type	default null	,
        p_dno_notice	in	DEL_NOTICES.DNO_NOTICE%type	default null	,
        p_dno_printable	in	DEL_NOTICES.DNO_PRINTABLE%type	default null	
    );
    
    procedure delete_notice(
        p_dno_id in number,
        p_dno_deleted_by in number
    ); 

  procedure create_travel(
    p_dtr_id out DEL_TRAVELS.DTR_ID%TYPE, 
    p_dde_id in DEL_TRAVELS.DDE_ID%TYPE,
    p_dtr_created_by in DEL_TRAVELS.DTR_CREATED_BY%TYPE,
    p_dtr_from in DEL_TRAVELS.DTR_FROM%TYPE,
    p_dtr_to in DEL_TRAVELS.DTR_TO%TYPE,
    p_dtr_date_from in DEL_TRAVELS.DTR_DATE_FROM%TYPE,
    p_dtr_date_to in DEL_TRAVELS.DTR_DATE_TO%TYPE,
    p_dtt_id in DEL_TRAVELS.DTT_ID%TYPE,
    p_dtr_distance in DEL_TRAVELS.DTR_DISTANCE%TYPE,
    p_dtr_factor in DEL_TRAVELS.DTR_FACTOR%TYPE,
    p_dtr_amount in DEL_TRAVELS.DTR_AMOUNT%TYPE  
    );
    
     procedure delete_travel (
        p_dtr_id in number,
        p_dtr_deleted_by in number
  );
  
    PROCEDURE create_cost
(
  p_dco_id          OUT DEL_COSTS.DCO_ID%TYPE,
  p_dde_id          IN  DEL_COSTS.DDE_ID%TYPE,
  p_dct_id          IN  DEL_COSTS.DCT_ID%TYPE,
  p_dco_created_by  IN  DEL_COSTS.DCO_CREATED_BY%TYPE,
  p_dct_description IN  DEL_COSTS.DCO_DESCRIPTION%TYPE,
  p_dco_amount      IN  DEL_COSTS.DCO_AMOUNT%TYPE
);

     procedure delete_cost (
        p_dco_id in number,
        p_dco_deleted_by in number
    );
 
TYPE t_text IS TABLE OF VARCHAR2(300);
TYPE t_number IS TABLE OF NUMBER;


     procedure create_action (
        p_dac_id out DEL_ACTIONS.DAC_ID%TYPE,
        p_dde_id in DEL_ACTIONS.DDE_ID%TYPE,
        p_dac_created_by in DEL_ACTIONS.DAC_CREATED_BY%TYPE,
        p_dac_created_role in DEL_ACTIONS.DAC_CREATED_ROLE%TYPE,
        p_dat_symbol in DEL_ACTION_TEMPLATES.DAT_SYMBOL%TYPE,
        p_tokens IN t_text, 
        p_texts IN t_text
  );
    
   procedure mark_for_print(
       p_dno_id in DEL_NOTICES.DNO_ID%TYPE default null,
       p_dqu_id in DEL_QUESTIONS.DQU_ID%TYPE default null,
       p_dac_id in DEL_ACTIONS.DAC_ID%TYPE default null
       ); 
    
   procedure create_calculation(
    p_dca_id out DEL_CALCULATIONS.DCA_ID%TYPE,
    p_dde_id in DEL_CALCULATIONS.DDE_ID%TYPE,
    p_dca_created_by in DEL_CALCULATIONS.DCA_CREATED_BY%TYPE
   ); 
    
   procedure init_delegations_year(
        p_ddn_year in DEL_DEL_NRS.DDN_YEAR%TYPE,
        p_ddn_last_nr in DEL_DEL_NRS.DDN_LAST_NR%TYPE default 0,
        p_ddn_created_by in DEL_DEL_NRS.DDN_CREATED_BY%TYPE
        );
    
  /* TODO enter package declarations (types, exceptions, methods etc) here */ 

END DEL_PKG;