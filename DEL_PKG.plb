create or replace PACKAGE BODY DEL_PKG AS

 function get_delegation_number(p_ddn_year in DEL_DEL_NRS.DDN_YEAR%TYPE default null)
  return number
  is
    l_ddn_last_nr DEL_DEL_NRS.DDN_LAST_NR%TYPE;
  begin
    select DDN_LAST_NR into l_ddn_last_nr from DEL_DEL_NRS where DDN_YEAR=nvl2(p_ddn_year,p_ddn_year, to_char(sysdate,'YYYY'));
    update DEL_DEL_NRS set DDN_LAST_NR=DDN_LAST_NR+1 where DDN_YEAR=nvl2(p_ddn_year,p_ddn_year, to_char(sysdate,'YYYY'));
    return l_ddn_last_nr;
  end;


  procedure create_delegation(
    p_dde_id out DEL_DELEGATIONS.DDE_ID%TYPE,
    p_dve_id in DEL_DELEGATIONS.DVE_ID%TYPE,
    p_dde_created_by in DEL_DELEGATIONS.DDE_CREATED_BY%TYPE,
    p_dde_approver in DEL_DELEGATIONS.DDE_APPROVER%TYPE,
    p_dde_oper_now_role in DEL_DELEGATIONS.DDE_OPER_NOW_ROLE%TYPE
  ) AS
  BEGIN
    insert into DEL_DELEGATIONS(
        DVE_ID,
        DDE_CREATED_BY,
        DDE_CREATED_ON,
        DDE_APPROVER,
        DDE_OPER_NOW_BY,
        DDE_OPER_NOW_ROLE,
        DDE_APPROVE_STATUS
    )values(
    p_dve_id,
    p_dde_created_by,
    sysdate,
    p_dde_approver,
    p_dde_created_by,
    p_dde_oper_now_role,
    'WAIT'
    ) returning DDE_ID into p_dde_id;
    
    NULL;
  END create_delegation;

procedure approve_delegation(
  p_dde_id in DEL_DELEGATIONS.DDE_ID%TYPE,
  p_dde_approved_by in DEL_DELEGATIONS.DDE_APPROVED_BY%TYPE,
  p_ddn_year in varchar2 default null
   ) AS
   l_dde_del_nr number;
  BEGIN
   l_dde_del_nr := get_delegation_number(p_ddn_year => p_ddn_year);
   
    update DEL_DELEGATIONS
  set 
      DDE_APPROVE_STATUS = 'APPROVED',
      DDE_APPROVED_BY =  p_dde_approved_by,
      DDE_APPROVED_ON = sysdate,
      DDE_DEL_NR = to_char(l_dde_del_nr) || '/' || nvl2(p_ddn_year,p_ddn_year,to_char( sysdate ,'YYYY' ))
    where DDE_ID = p_dde_id;
    
    -- Dodaæ numerowanie delegacji!
    
  END approve_delegation;
  
  procedure reject_delegation(
  p_dde_id in DEL_DELEGATIONS.DDE_ID%TYPE,
  p_dde_approved_by in DEL_DELEGATIONS.DDE_APPROVED_BY%TYPE
   ) AS
  BEGIN
    update DEL_DELEGATIONS
  set 
      DDE_APPROVE_STATUS = 'REJECTED',
      DDE_APPROVED_BY =  p_dde_approved_by,
      DDE_APPROVED_ON = sysdate
    where DDE_ID=p_dde_id;
  END reject_delegation;


  procedure create_proposition(
   p_dpr_id out DEL_PROPOSITIONS.DPR_ID%TYPE,
   p_dde_id in DEL_PROPOSITIONS.DDE_ID%TYPE,
   p_dpr_created_by in DEL_PROPOSITIONS.DPR_CREATED_BY%TYPE,
   p_dpr_destination in DEL_PROPOSITIONS.DPR_DESTINATION%TYPE,
   p_dpr_date_from in DEL_PROPOSITIONS.DPR_DATE_FROM%TYPE,
   p_dpr_date_to in DEL_PROPOSITIONS.DPR_DATE_TO%TYPE,
   p_dtt_ids in DEL_PROPOSITIONS.DTT_IDS%TYPE,
   p_dpr_purpose in DEL_PROPOSITIONS.DPR_PURPOSE%TYPE
  ) as
  begin
    insert into DEL_PROPOSITIONS (
        DDE_ID,
        DPR_CREATED_BY,
        DPR_CREATED_ON,
        DPR_DESTINATION,
        DPR_DATE_FROM,
        DPR_DATE_TO,
        DTT_IDS,
        DPR_PURPOSE    
    )values(
      p_dde_id,
      p_dpr_created_by,
      sysdate,
      p_dpr_destination,
      p_dpr_date_from,
      p_dpr_date_to,
      p_dtt_ids,
      p_dpr_purpose
    ) returning DPR_ID into p_dpr_id;
  end;

 procedure create_question(
      p_dqu_id out DEL_QUESTIONS.DQU_ID%TYPE,
      p_dpr_id in DEL_QUESTIONS.DPR_ID%TYPE,
      p_dde_id in DEL_QUESTIONS.DDE_ID%TYPE,
      p_created_by in DEL_QUESTIONS.DQU_CREATED_BY%TYPE,
      p_dqu_recipient_role in DEL_QUESTIONS.DQU_RECIPIENT_ROLE%TYPE,
      p_dqu_recipient in DEL_QUESTIONS.DQU_RECIPIENT%TYPE,
      p_dqu_question in DEL_QUESTIONS.DQU_QUESTION%TYPE,
      p_dqu_printable in DEL_QUESTIONS.DQU_PRINTABLE%TYPE
  ) AS
  BEGIN 
  insert into DEL_QUESTIONS(
        DPR_ID,
        DDE_ID,
        DQU_CREATED_BY,
        DQU_CREATED_ON,
        DQU_RECIPIENT_ROLE,
        DQU_RECIPIENT,
        DQU_QUESTION,
        DQU_PRINTABLE
    ) values (
      p_dpr_id,
      p_dde_id,
      p_created_by,
      sysdate,
      p_dqu_recipient_role,
      p_dqu_recipient,
      p_dqu_question,
      p_dqu_printable)
  returning DQU_ID into p_dqu_id; 
  END create_question;
  
   procedure answer_question(
  p_dqu_id in DEL_QUESTIONS.DQU_ID%TYPE,
  p_dqu_answer in DEL_QUESTIONS.DQU_ANSWER%TYPE,
  p_dqu_answered_by in DEL_QUESTIONS.DQU_ANSWERED_BY%TYPE
  ) AS
  BEGIN
    update DEL_QUESTIONS
  set 
      DQU_ANSWER = p_dqu_answer,
      DQU_ANSWERED_BY =  p_dqu_answered_by,
      DQU_ANSWERED_ON = sysdate
      where DQU_ID=p_dqu_id;
  END answer_question;
  
  procedure delete_question(
    p_dqu_id in number,
    p_dqu_deleted_by in number) AS
  BEGIN
    update DEL_QUESTIONS
    set 
     DQU_DELETED_ON = sysdate,
     DQU_DELETED_BY = p_dqu_deleted_by
    where DQU_ID = p_dqu_id;
  END delete_question;

procedure create_notice(
        p_dno_id	out	DEL_NOTICES.DNO_ID%type,
        p_dpr_id	in	DEL_NOTICES.DPR_ID%type	default null	,
        p_dde_id	in	DEL_NOTICES.DDE_ID%type	default null	,
        p_dno_created_by	in	DEL_NOTICES.DNO_CREATED_BY%type	default null	,
        p_dno_notice	in	DEL_NOTICES.DNO_NOTICE%type	default null	,
        p_dno_printable	in	DEL_NOTICES.DNO_PRINTABLE%type	default null	
    )
  as
  begin
    insert into DEL_NOTICES (
        	DPR_ID
      ,	DDE_ID
      ,	DNO_CREATED_BY
      ,	DNO_CREATED_ON
      ,	DNO_NOTICE
      ,	DNO_PRINTABLE  
    )values(
    	p_dpr_id
    ,	p_dde_id
    ,	p_dno_created_by
    ,	sysdate
    ,	p_dno_notice
    ,	p_dno_printable
    ) returning DNO_ID into p_dno_id;
  end;


  procedure delete_notice(
    p_dno_id in number,
    p_dno_deleted_by in number) AS
  BEGIN
    update DEL_NOTICES
    set 
     DNO_DELETED_ON = sysdate,
     DNO_DELETED_BY = p_dno_deleted_by
    where DNO_ID = p_dno_id;
  END delete_notice;


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
    ) AS
  BEGIN 
  insert into DEL_TRAVELS(
      DDE_ID,
      DTR_CREATED_BY,
      DTR_CREATED_ON,
      DTR_FROM,
      DTR_TO,
      DTR_DATE_FROM,
      DTR_DATE_TO,
      DTT_ID,
      DTR_DISTANCE,
      DTR_FACTOR,
      DTR_AMOUNT)
        values (
      p_dde_id,
      p_dtr_created_by,
      sysdate,
      p_dtr_from,
      p_dtr_to,
      p_dtr_date_from,
      p_dtr_date_to,
      p_dtt_id,
      p_dtr_distance,
      p_dtr_factor,
      p_dtr_amount)
      returning DTR_ID into p_dtr_id;
      NULL;
    END create_travel;
  
   procedure delete_travel (
        p_dtr_id in number,
        p_dtr_deleted_by in number
  ) AS  
  BEGIN
    update DEL_TRAVELS
    set 
     DTR_DELETED_ON = sysdate,
     DTR_DELETED_BY = p_dtr_deleted_by
    where DTR_ID = p_dtr_id;   
  END delete_travel;  


 PROCEDURE create_cost
  (
  p_dco_id          OUT DEL_COSTS.DCO_ID%TYPE,
  p_dde_id          IN  DEL_COSTS.DDE_ID%TYPE,
  p_dct_id          IN  DEL_COSTS.DCT_ID%TYPE,
  p_dco_created_by  IN  DEL_COSTS.DCO_CREATED_BY%TYPE,
  p_dct_description IN  DEL_COSTS.DCO_DESCRIPTION%TYPE,
  p_dco_amount      IN  DEL_COSTS.DCO_AMOUNT%TYPE
) AS
  BEGIN
    INSERT INTO del_costs
    (
      DDE_ID,
      DCT_ID,
      DCO_DESCRIPTION,
      DCO_AMOUNT,
      DCO_CREATED_BY,
      DCO_CREATED_ON
    )
    VALUES
    (
      p_dde_id,
      p_dct_id,
      p_dct_description,
      p_dco_amount,
      p_dco_created_by,
      sysdate
    )
    RETURNING DCO_ID INTO p_dco_id;
  END create_cost;

  procedure delete_cost (
        p_dco_id in number,
        p_dco_deleted_by in number
  ) AS  
  BEGIN
    update DEL_COSTS
    set 
     DCO_DELETED_ON = sysdate,
     DCO_DELETED_BY = p_dco_deleted_by
    where DCO_ID = p_dco_id;
    
  END delete_cost;  
 
 FUNCTION multiple_replace(
  p_template IN VARCHAR2, p_old IN t_text, p_new IN t_text
)
  RETURN VARCHAR2
AS
  v_result VARCHAR2(32767);
BEGIN
  IF( p_old.COUNT <> p_new.COUNT ) THEN
    RETURN p_template;
  END IF;
  v_result := p_template;
  FOR i IN 1 .. p_old.COUNT LOOP
    v_result := REPLACE( v_result, p_old(i), p_new(i) );
  END LOOP;
  RETURN v_result;
END; 
  
    procedure create_action (
        p_dac_id out DEL_ACTIONS.DAC_ID%TYPE,
        p_dde_id in DEL_ACTIONS.DDE_ID%TYPE,
        p_dac_created_by in DEL_ACTIONS.DAC_CREATED_BY%TYPE,
        p_dac_created_role in DEL_ACTIONS.DAC_CREATED_ROLE%TYPE,
        --p_dac_created_on in DEL_ACTIONS.DAC_CREATED_ON%TYPE,--tu mamy domyslnie sysdate
        p_dat_symbol in DEL_ACTION_TEMPLATES.DAT_SYMBOL%TYPE,
        p_tokens IN t_text, 
        p_texts IN t_text
      --,  p_dac_printable in DEL_ACTIONS.DAC_PRINTABLE%TYPE --tu nie wiem czy coœ domyslnie ustawiaæ
  ) AS
  l_dac_details varchar2(4000);
  l_template varchar2(4000);
  l_dat_id number;
  BEGIN
   
    
     select dat_id, dat_text
            into 
            l_dat_id, l_template from  
           del_action_templates
              where dat_symbol = p_dat_symbol;
  
   l_dac_details := multiple_replace(
           p_template => l_template, 
           p_old => p_tokens, 
           p_new => p_texts);
  
    insert into DEL_ACTIONS(
        DAC_ID,
        DDE_ID,
        DAC_CREATED_BY,
        DAC_CREATED_ROLE,
        DAC_CREATED_ON,
        DAT_ID,
        DAC_DETAILS
       -- , DAC_PRINTABLE
    )values(
        p_dac_id ,
        p_dde_id ,
        p_dac_created_by ,
        p_dac_created_role ,
        sysdate ,
        l_dat_id ,
        l_dac_details 
        --, p_dac_printable 
    ) returning DAC_ID into p_dac_id; 
  END create_action ;

  procedure mark_for_print(
       p_dno_id in DEL_NOTICES.DNO_ID%TYPE default null,
       p_dqu_id in DEL_QUESTIONS.DQU_ID%TYPE default null,
       p_dac_id in DEL_ACTIONS.DAC_ID%TYPE default null
  ) as
  begin
   update DEL_NOTICES 
   set DNO_PRINTABLE=nvl2(DNO_PRINTABLE , null,'Y')
    where DNO_ID = p_dno_id;
    
   update DEL_QUESTIONS 
   set DQU_PRINTABLE=nvl2(DQU_PRINTABLE , null,'Y')
    where DQU_ID = p_dqu_id;
    
   update DEL_ACTIONS 
   set DAC_PRINTABLE=nvl2(DAC_PRINTABLE , null,'Y')
    where DAC_ID = p_dac_id;
    
  end;

   procedure create_calculation(
    p_dca_id out DEL_CALCULATIONS.DCA_ID%TYPE,
    p_dde_id in DEL_CALCULATIONS.DDE_ID%TYPE,
    p_dca_created_by in DEL_CALCULATIONS.DCA_CREATED_BY%TYPE
   )as
   begin
      insert into DEL_CALCULATIONS
      (
        DDE_ID,
        DCA_CREATED_BY,
        DCA_CREATED_ON
      )values(
        p_dde_id,
        p_dca_created_by,
        sysdate
      ) returning DCA_ID into p_dca_id;
      
      for x in (select * from DEL_TRAVELS where DDE_ID=p_dde_id and DTR_DELETED_ON is null)
         loop
          insert into DEL_CALCULATION_DETAILS
              (DCA_ID, DTR_ID)
          values (p_dca_id, x.DTR_ID);
         end loop;
      
      for x in (select * from DEL_COSTS where DDE_ID=p_dde_id and DCO_DELETED_ON is null)
         loop
          insert into DEL_CALCULATION_DETAILS
              (DCA_ID, DCO_ID)
          values (p_dca_id, x.DCO_ID);
         end loop;   
      
   end; 


   procedure init_delegations_year(
        p_ddn_year in DEL_DEL_NRS.DDN_YEAR%TYPE,
        p_ddn_last_nr in DEL_DEL_NRS.DDN_LAST_NR%TYPE default 0,
        p_ddn_created_by in DEL_DEL_NRS.DDN_CREATED_BY%TYPE
        )
        as
        
        l_exists number;
    begin
      
      select count(*) into l_exists from DEL_DEL_NRS where DDN_YEAR=p_ddn_year;   
      if l_exists =0
      then
        insert into DEL_DEL_NRS (
            DDN_YEAR, 
            DDN_LAST_NR,
            DDN_CREATED_BY, 
            DDN_CREATED_ON 
        ) values(
            p_ddn_year,
            p_ddn_last_nr,
            p_ddn_created_by,
            sysdate
        );
      else
        raise_application_error( -20001, 'Year already exists!' );
      end if;
        
      null;
    end;
    



END DEL_PKG;