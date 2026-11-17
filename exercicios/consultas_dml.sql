-- Active: 1794937875005@@127.0.0.1@5432@atividade_dml
CREATE TABLE IF NOT EXISTS pessoa (
    cpf CHAR(11) PRIMARY KEY,
    email VARCHAR(50) NOT NULL,
    nome VARCHAR(150) NOT NULL,
    data_nasc DATE NOT NULL,
    endereco VARCHAR(300) NOT NULL,
    telefone VARCHAR(15) NULL
);

CREATE TABLE IF NOT EXISTS paciente (
    cpf CHAR(11) PRIMARY KEY REFERENCES pessoa(cpf) ON DELETE CASCADE,
    senha VARCHAR(10) NOT NULL CHECK (LENGTH(senha) BETWEEN 5 AND 10),
    plano_saude BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS medico (
    cpf CHAR(11) PRIMARY KEY REFERENCES pessoa(cpf) ON DELETE CASCADE,
    crm VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS especialidade (
    identificador SERIAL PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS medico_especialidade (
    cpf_medico CHAR(11) REFERENCES medico(cpf) ON DELETE CASCADE,
    identificador_especialidade INT REFERENCES especialidade(identificador) ON DELETE CASCADE,
    PRIMARY KEY (cpf_medico, identificador_especialidade)
);

CREATE TABLE IF NOT EXISTS agendamento (
    cpf_paciente CHAR(11) REFERENCES paciente(cpf) ON DELETE CASCADE,
    cpf_medico CHAR(11) REFERENCES medico(cpf) ON DELETE CASCADE,
    data_hora_consulta TIMESTAMP NOT NULL,
    data_hora_agendamento TIMESTAMP NOT NULL,
    valor_consulta NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (cpf_paciente, cpf_medico, data_hora_consulta)
);

INSERT INTO pessoa (nome, email, cpf, data_nasc, endereco, telefone) VALUES
    ('Pedro I', 'pp@email.com', '002', '1479-01-10', 'R. Vasco', NULL),
    ('Pedro II', 'ps@email.com', '003', '1516-02-10', 'R. Flamengo', '5501'),
    ('D João VI', 'dj@email.com', '001', '1415-12-01', 'R. Portugal', NULL),
    ('JJ Xavier', 'jj@email.com', '004', '1746-11-12', 'R. Minas', '5502');

INSERT INTO paciente (cpf, senha, plano_saude) VALUES
    ('002', 'senha1', FALSE),
    ('003', 'senha2', TRUE);

INSERT INTO medico (cpf, crm) VALUES
    ('001', '111'),
    ('004', '112');

INSERT INTO especialidade (descricao) VALUES
    ('Pediatra'),
    ('Cardiologista'),
    ('Ortopedista');

INSERT INTO medico_especialidade (cpf_medico, identificador_especialidade) VALUES
    ('001', 1),
    ('004', 2),
    ('004', 3);

INSERT INTO agendamento (cpf_paciente, cpf_medico, data_hora_consulta, data_hora_agendamento, valor_consulta) VALUES
    ('002', '001', '1782-04-14 16:00:00', '1782-03-14 10:04:45', 80.00),
    ('002', '004', '1782-04-15 10:00:00', '1782-03-14 10:04:45', 100.00),
    ('002', '004', '1783-05-17 08:00:00', '1783-05-10 16:32:00', 100.00),
    ('003', '001', '1783-05-17 08:30:00', '1783-05-09 09:05:56', 0.00);

UPDATE pessoa
SET data_nasc = '1416-12-01'
WHERE nome = 'D João VI';

UPDATE pessoa
SET telefone = '5503',
    email = 'pf@email.com'
WHERE nome = 'Pedro I';

UPDATE pessoa
SET telefone = '9' || telefone
WHERE telefone IS NOT NULL;

UPDATE agendamento
SET data_hora_consulta = data_hora_consulta + INTERVAL '2 days',
    valor_consulta = 150.00
WHERE DATE(data_hora_consulta) = '1783-05-17';

DELETE FROM medico_especialidade
WHERE cpf_medico = (SELECT cpf FROM pessoa WHERE nome = 'JJ Xavier')
  AND identificador_especialidade = (SELECT identificador FROM especialidade WHERE descricao = 'Cardiologista');

INSERT INTO medico_especialidade (cpf_medico, identificador_especialidade)
VALUES (
    (SELECT cpf FROM pessoa WHERE nome = 'JJ Xavier'),
    (SELECT identificador FROM especialidade WHERE descricao = 'Pediatra')
);

DELETE FROM agendamento
WHERE cpf_paciente = (SELECT cpf FROM pessoa WHERE nome = 'Pedro I')
  AND DATE(data_hora_consulta) = '1783-05-19';

DELETE FROM agendamento
WHERE cpf_medico = (SELECT cpf FROM pessoa WHERE nome = 'D João VI')
  AND valor_consulta = 0.00;

DELETE FROM paciente
WHERE plano_saude = TRUE
   OR cpf IN (SELECT cpf FROM pessoa WHERE telefone IS NULL);

DELETE FROM medico
WHERE cpf = (SELECT cpf FROM pessoa WHERE nome = 'JJ Xavier');

