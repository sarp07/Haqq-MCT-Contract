# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```

# Sözleşme işlevsellikleri 

Bu sözleşme yapısı aşağıdaki ana maddeleri içermektedir. 

 - Güncellenebilir yapıda olmalıdır. Proxy address kullanılarak ilerleyen süreçlerde ihtiyaca göre fonksiyon eklenebilir veya değiştirilebilir.
 - Invest fonksiyonuna sahip olmalıdır. TrafnsferFrom(msg.sender), this(address) gibi. 
 - Investment kaydı tutulmalıdır. Örnek ;
    * Investor ID
    * Investor Addr
    * Invest Amount
    * Invest Time
    * Loan Start Time
    * Repayment Budget 
    * Loan Circle
 
 - Moderatör yönetimine sahip olmalıdır. Remove ve Add fonksiyonları olmalıdır. 
 - Kredi Ödemeleri yapılmasını sağlayan ve onlyModerator modifier'ına sahip fonksiyon olmalıdır. 
 - Kredi ödeme ve paydalarında ek olarak her krediden kredi tutarının %20 servis ücreti olarak eklenir ve kredi ödemeleri o servis ücretleri dahil yapılır. 
 Bu kredi ödemelerinde yatırımcının karı kullandırılan kredi tutarının %4'üne eşittir. %10'u TGMP vakfına ait %6'sı platforma aittir. Bu tarz geri ödeme koşullarında kredi ödeme fonksiyonları bu şartlara uygun olmalıdır. 
 - Kredi geri ödemelerin servis ücret olmadan toplanan ana para ve kar payları ayrılmalıdır. Yatırımcı hem anaparası hemde %4'lük kar payı için ayrı withdrawal fonksiyonları kullanarak çekim yapmalıdır. Ana para çekim işlemlerinde yatırımcının anaparayı tekrar kredi vermek için kullanıp kullanmayacağını belirleyen Loan Circle adıdna bir boolean değişken olmalıdır. 
