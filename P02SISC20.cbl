      $set sourceformat"free"
      *>----Divis�o de identifica��o do programa
       identification division.
       program-id. "P02SISC20".
       author. "Julia Kr�ger".
       installation. "PC".
       date-written. 03/08/2020.
       date-compiled. 03/08/2020.

      *>----Divis�o para configura��o do ambiente
       environment division.
       configuration section.
       special-names.
       decimal-point is comma.

      *>----Declara��o dos recursos externos
       input-output section.
       file-control.

           select arq-resultados assign to "arq-resultados.dat"
           organization is indexed
           access mode is dynamic
           lock mode is manual with lock on multiple records
           record key is fl-resul-chave-resul
           alternate key is fl-resul-user-id with duplicates
           alternate key is fl-resul-id-disciplina with duplicates
           file status is ws-fs-arq-resultados.

       i-o-control.


      *> SABER SE QUER REGISTRAR UM REDULTADO OU LER UM RESULTADO

      *>----Declara��o de vari�veis
       data division.

      *>----Vari�veis de arquivos
       file section.
       fd arq-resultados.
       01 fl-resultado.
           05 fl-resul-chave-resul.
               10 fl-resul-id-resultado            pic 9(02).
               10 fl-resul-user-id                 pic x(10).
           05 fl-resul-id-disciplina               pic x(10).
           05 fl-resul-nota                        pic 9(02)V99.
           05 fl-resul-data-prova                  pic 9(10).

      *>----Vari�veis de trabalho
       working-storage section.
       77 ws-fs-arq-resultados                     pic x(02).

       01 ws-resultado.
           05 ws-resul-chave-resul.
               10 ws-resul-id-resultado            pic 9(02).
               10 ws-resul-user-id                 pic x(08).
           05 ws-resul-id-disciplina               pic x(10).
           05 ws-resul-nota                        pic 9(02)V99.
           05 ws-resul-data-prova                  pic 9(10).

       01 ws-msn-erro.
          05 ws-msn-erro-ofsset                    pic 9(04).
          05 filler                                pic x(01) value "-".
          05 ws-msn-erro-cod                       pic x(02).
          05 filler                                pic x(01) value space.
          05 ws-msn-erro-text                      pic x(42).

       77 ws-resul-msn                             pic x(39).
       77 ws-tipo-usuario-adm                      pic x(01).
       77 ws-tipo-usuario-f                        pic x(01).
       77 ws-resul-sair                            pic x(01).
       77 ws-resul-proximo                         pic x(01).


      *>----Vari�veis para comunica��o entre programas
       linkage section.


      *>----Declara��o de tela
       screen section.

      *> TELA PARA RECEBER OS DADOS DO FUNCIONARIO QUE O ADM QUER CONSULTAR OS RESULTADOS (USER-ID)
      *> TELA PARA MOSTRAR OS RESULTADOS DO FUNCIONARIO (USER-ID, ID-RESUL, ID-DISCIPLINA(VAI MOSTRAR OS RESULTADOS DE TODAS AS DISCIPLINAS,
      *> NOTA E DATA DA PROVA)



      *>                                0    1    1    2    2    3    3    4    4    5    5    6    6    7    7    8
      *>                                5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0
      *>                            ----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
       01 sc-tela.
           05 blank screen.
           05 line 01 col 01 value "          CONSULTA DE RESULTADOS                                                "
           foreground-color 12.
           05 line 03 col 01 value "********************************************                                    ".
           05 line 04 col 01 value "********************************************                                    ".
           05 line 05 col 01 value "**                                        **                                    ".
           05 line 06 col 01 value "**                                        **                                    ".
           05 line 07 col 01 value "**  ID DO FUNCIONARIO:                    **                                    ".
           05 line 08 col 01 value "**                                        **                                    ".
           05 line 09 col 01 value "**                                        **                                    ".
           05 line 10 col 01 value "**                                        **                                    ".
           05 line 11 col 01 value "********************************************                                    ".
           05 line 12 col 01 value "********************************************                                    ".




      *>                                0    1    1    2    2    3    3    4    4    5    5    6    6    7    7    8
      *>                                5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0
      *>                            ----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
       01 sc-tela.
           05 blank screen.
           05 line 01 col 01 value "                        CONSULTA DE RESULTADOS                                  "
           foreground-color 12.
           05 line 03 col 01 value "  ID DO FUNCIONARIO:                                                            ".
           05 line 05 col 01 value "  DISCIPLINA:                                                                   ".
           05 line 07 col 01 value "  QUANTIDADE DE ACERTOS:                                                        ".
           05 line 09 col 01 value "  NOTA DA PROVA:                                                                ".
           05 line 11 col 01 value "  DATA DA PROVA:                                                                ".
           05 line 12 col 01 value "                                                          [ ]Proxima Disciplina ".
           05 line 13 col 01 value "                                                          [ ]Sair               ".



      *>Declara��o do corpo do programa
       procedure division.

       0000-controle section.
           perform 1000-inicializa
           perform 2000-processamento
           perform 3000-finaliza
           .
       0000-controle-exit.
           exit.

       1000-inicializa section.
           open i-o arq-resultados                 *> open i-o abre o arquivo para leitura e escrita
           if ws-fs-arq-resultados  <> "00"
           and ws-fs-arq-resultados <> "05" then
               move 1                                   to ws-msn-erro-ofsset
               move ws-fs-arq-resultados                to ws-msn-erro-cod
               move "Erro ao abrir arq. arqresultados"  to ws-msn-erro-text
               perform finaliza-anormal
           end-if
           .
       1000-inicializa-exit.
           exit.

       2000-processamento section.


           if   ws-tipo-usuario-adm = "x" or ws-tipo-usuario-adm = "X" then
                perform until ws-resul-sair = "x" or ws-resul-sair = "X"
                   move ws-resul-user-id to fl-resul-user-id
                   read arq-resultados
                   if   ws-fs-arq-resultados  <> "00" then
                       if   ws-fs-arq-resultados = 23 then
                           move "Funcionario invalido ou nao fez a prova" to ws-resul-msn
                       else
                           move 2                                     to ws-msn-erro-ofsset
                           move ws-fs-arq-resultados                  to ws-msn-erro-cod
                           move "Erro ao ler arq. arq-resultados"     to ws-msn-erro-text
                           perform finaliza-anormal
                       end-if
                   move fl-resultado to ws-resultado
                   end-if
      *>    DISPLAY TELA INFORMA��ES
      *>    ACEITAR SE QUER PR�XIMO OU SAIR
                end-perform
           end-if

           if   ws-tipo-usuario-f = "x" or ws-tipo-usuario-f = "X" then
                move ws-resultado to fl-resultado
                write fl-resultado
                if   ws-fs-arq-resultados  <> "00" then
                     move 3                                       to ws-msn-erro-ofsset
                     move ws-fs-arq-resultados                    to ws-msn-erro-cod
                     move "Erro ao escrever arq. arq-resultados"  to ws-msn-erro-text
                     perform finaliza-anormal
                end-if


      *> SE O USUARIO FOR ADMIN ELE VAI PODER CONSULTAR AS RESPOSTAS DOS FUNCIONARIOS COLOCANDO O ID DO FUNCIONARIO
      *> O QUE VAI APARECER NA TELA DE CONSULTA: ID DO FUNCIONARIO, QUANTIDADE DE ACERTOS (ID-RESUL), ID DA DISCIPLINA, NOTA E DATA DA PROVA

      *> PUXAR ESSE PROGRAMA JUNTO DA PROVA, PARA ARMAZENAR O NUMERO DE ACERTOS
           .
       2000-processamento-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Finaliza��o  Anormal
      *>------------------------------------------------------------------------
       finaliza-anormal section.
           display erase
           display ws-msn-erro.
           stop run
           .
       finaliza-anormal-exit.
           exit.

      *>------------------------------------------------------------------------
      *> Finaliza��o Normal
      *>------------------------------------------------------------------------
       3000-finaliza section.
           close arq-resultados
           if ws-fs-arq-resultados  <> "00" then
               move 4                                     to ws-msn-erro-ofsset
               move ws-fs-arq-resultados                  to ws-msn-erro-cod
               move "Erro ao fechar arq. arq-resultados"  to ws-msn-erro-text
               perform finaliza-anormal
           end-if

           stop run
           .
       3000-finaliza-exit.
           exit.




