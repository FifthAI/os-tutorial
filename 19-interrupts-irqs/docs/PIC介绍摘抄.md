PIC中斷控制器介紹
在一般的電腦系統裡，當裝備需要系統來服務時.有二種方法：一是 polling，由CPU一直去問裝備是否需要服務，如果需要時就去服務它，但這很浪費 CPU 的時間，另一種方法就是IRQ的方式，當Device需耍服務時就發出IRQ，當系統收到這個IRQ訊號時才去服務它，這樣可大大減小系統的負擔。
PIC(Programmable Interrupt Controller)介紹
IRQ是由中斷控制器所處理的，中斷控制器用以連接Device和CPU的重要橋梁，一個Device產生中斷後，需經過中斷控制器的轉發，訊號才能到達CPU。中斷控制器經歷了PIC(Programmable Interrupt Controller可編程中斷控制器)和APIC(Advanced Programmable Interrupt Controller高級可編程中斷控制器)兩個階段。PIC在UP(Uni-processor單處理器)上使用，隨著SMP(Symmetric Multiple Processor對稱式多重處理器)開始使用，APIC已漸漸取代PIC了。
每一個PIC可處理八個中斷輸入，但是現在的系統多半由兩個PIC來處理，所以全部可以處理十六個中斷，由IRQ0~IRQ15，但是第二個PIC的輸出需要接到第一個PIC的其中一個輸入，所以最多只能處理到十五個中斷請求，而這個被用掉的輸入就是IRQ2。
與APIC不同的是，PIC每個IRQ都具有優先權，以IRQ0最高，也就是IRQ編號愈小的擁有愈高的中斷優先權。用於當有兩個Device同時發出IRQ時，就以這個順序來決定誰先被服務。由於IRQ2被當成第二個中斷控制器的輸入，所以整個中斷請求的順序為：
0 , 1 , 2 ( 8 , 9 , 10 , 11 , 12 , 13 , 14 , 15 ) , 3 , 4 , 5 , 6 , 7.
一般來說十五個 IRQ 被設定為下列裝備 :
IRQ 0 : System timer. 系統時間.

IRQ 1 : Keyboard. 鍵盤.

IRQ 3 : Com2. 串列埠.

IRQ 4 : Com1. 串列埠.

IRQ 5 : Parallel port 2. 並列埠

IRQ 6 : Floppy Disk. 軟碟機.

IRQ 7 : Parallel port 1. 並列埠.

IRQ 8 : Real Time Clock. 時鐘.

IRQ 9 : INT 0AH

IRQ 10 : 保留

IRQ 11 : 保留

IRQ 12 : PS/2 mouse. 滑鼠.

IRQ 13 : Coprocessor. 輔助(協)處理器.

IRQ 14 : Primary IDE. 主 IDE. 如硬碟機.

IRQ 15 : Secondary IDE. 副 IDE.