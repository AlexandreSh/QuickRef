# Implementado com sucesso com a chave Identiv Utrust NFC, em deb Sid e Kali. Apenas multi-user.target


Consideração inicial: O suporte a linux da utrust é um completo dissabor, mas se você precisar trocar o resetar o PIN de sua chave, o software deles para windows funcionou sem problemas notáveis numa ova win7 com passthrough do hub usb da chave.
Saiba o pin a priori pois alguns passos vão te requisitar ele.

Instala a biblioteca
```
sudo apt-get install libpam-u2f
```
Cria o arquivo com a chave, pode ser na pasta que você quiser, com o nome que você quiser, mas você tem que ser capaz de acessar ela antes de logar (nada de drives encriptados)

Depois do comando a chave vai pedir piscar, aí aperta o que seu dispositivo tiver
```
pamu2fcfg | sudo tee /etc/u2f_keys
```
Verificando a chave
```
sudo nano /etc/pam.d/sudo
```
vai ter a linha "@include common-auth:", logo embaixo dela coloca
```
auth       required   pam_u2f.so authfile=/etc/u2f_keys
```
crtl+O para salvar e não feche o terminal. Retira a chave e abre uma outra aba ou janela do terminal e 
```
sudo echo echo
```
quando você digitar a sua senha o comando deve falhar. Coloca a chave de volta, abre um novo terminal e digta de novo.

Desta vez deve pedir pra apertar o botão da chave depois da sua senha e funcionar depois de apertado.

Depois disso funcionar, volte o /etc/pam.d/sudo para a versão original.

#### Se algum passo até aqui falhar, não avance ou você vai precisar procurar um tutorial de chroot.

para modificar o meio de login:

```
sudo nano /etc/pam.d/common-auth
```
para adicionar um novo fator além da sua senha, adicione esta linha ao final do arquivo:
```
auth    required   pam_u2f.so nouserok authfile=/etc/u2f_keys cue
```
para adicionar um novo fator alternativo à senha, adicione esta linha logo antes da linha "auth    [success=1 default=ignore]      pam_unix.so nullok:". Deve ser a primeira linha não comentada.
```
auth    sufficient pam_u2f.so nouserok authfile=/etc/u2f_keys pinverification=0 cue
```
Fontes utilizadas:
```
https://developers.yubico.com/pam-u2f/
```
```
https://askubuntu.com/questions/1071027/how-to-configure-a-u2f-keysuch-as-a-yubikey-for-system-wide-2-factor-authentic
```
