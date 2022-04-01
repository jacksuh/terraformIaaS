# Terraform

Esse projeto esta utilizando a versão [Terraform](https://www.terraform.io/downloads) Version: 1.1.7

Azurerm [azurerm](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli) Version: 2.26.0

## Sobre o projeto

Projeto foi realizado para praticar os conhecimentos em ambiente IaaS utilizando o Microsoft azure.<br>
Instalação e configuração da maquina virtual com o apache2, com acesso ip externo.


## Comandos

- terraform init: Inicializa o ambiente com o provedor utilizado. Responsável por fazer o download dos plugins e demais arquivos necessários para  a correta execução;

- terraform plan: Faz a leitura dos arquivos TF, testa as configurações, e monta o plano de execução do Terraform.

- terraform apply: Executa a “criação” dos recursos (instâncias) no provider indicado nos arquivos TF

- terraform validate:  comando é usado para validar a sintaxe dos arquivos terraform. O Terraform executa uma verificação de sintaxe em todos os arquivos do terraform no diretório e exibirá um erro se algum dos arquivos não for validado.

- terraform destroy:  Executa a “remoção” dos recursos (instâncias) no provider indicado nos arquivos TF
