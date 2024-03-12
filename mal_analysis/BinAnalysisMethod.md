## ELF Malware/Binary Analysis Methodology

### Information Gathering

* Detail: Identify and document system details pertaining to the system from which the suspect file was obtained.

* Hash: Obtain a cryptographic hash value or “digital fingerprint” of the suspect file.

* Compare: Conduct file similarity indexing of the file against known samples.

* Classify: Identify and classify the type of file (including the file format and the target architecture/platform), the high level language used to author the code, and the compiler used to compile it.

* Visualize: Examine and compare suspect files in graphical representation, revealing visual distribution of the file contents.

* Scan: Scan the suspect file with anti-virus and anti-spyware software to determine whether the file has a known malicious code signature.

* Examine: Examine the file with executable file analysis tools to ascertain whether the file has malware properties.

* Extract and Analyze: Conduct entity extraction and analysis on the suspect file by reviewing any embedded American Standard Code for Information Interchange (ASCII) or Unicode strings contained within the file, and by identifying and reviewing any file metadata and symbolic information.

* Reveal: Identify any code obfuscation or armoring techniques protecting the file from examination, including packers, wrappers, or encryption.

* Correlate: Determine whether the file is dynamically or statically linked, and identify whether the file has dependencies.

* Research: Conduct online research relating to the information you gathered from the suspect file and determine whether the file has already been identified and analyzed by security consultants, or conversely, whether the file information is referenced on hacker or other nefarious Web sites, forums, or blogs.


### Questions about the suspicious file
```
- Is the file executable?
  $ file <file>

- Is the file a binary?
  $ file <file>

- For which architecture (x86, or x86_64) is the binary compiled?
  $ file <file>

- Which format is the binary? (Hopefully ELF, otherwise the rest of this book is going to be pointless.)
  $ file <file>

- Is the binary stripped of its symbol table?
  $ file <file>

- Can we identify any useful strings within the binary?
  $ strings <file>

- What's the SHA hash of the binary?
  $ sha265sum <file>

- Does the hash come back as a known malicious file hash?
  Search in gugou

- Can we identify any useful function names?
  $ readelf -s <file> (symbols table)
  
- Can we identify any libraries used?
  $ readelf -s <file> (symbols table) or $ ldd  

- What was the original programming language used?
  try find language indicators with static analysis
  
|======================================
|               - What is the functionality and capability of the file?
|    ONLY           
|               - What does the file suggest about the sophistication level of the attacker?
|   DYNAMIC           
|               - What does the file suggest about the sophistication level of the coder?
|   ANALYSIS            
|               - What is the target of the file is it customized to the victim system/network or a general attack?
|    !!!!!!
|               - When was the binary written to disk?
|======================================
```


### Identify Packed Binary: 

* Detec It Easy (DIE) tool

* As we start reversing a malware one of the first things we should check is the packing. Usually we will quickly see that a program is packed as it will contain a bunch of nonsense strings along with very few internal functions and imports. Parts on the code may also include several loops with opcodes related to xor and other potential decode/decrypt functions. Though it is an aprox, it doesn’t have to be exactly like this.
A high entropy on the binary may also be a clear indicator that it is packed, as obviously an encrypted payload (that is, generated by an encryption/compression) algorithm will increase the entropy of the file. (https://artik.blue/malware3)

* "The segment table contains only PT_LOAD and PT_GNU_STACK segments. This is an anomaly in the segment tables structure that might indicate the file is packed."

* First, when you query the target file to identify the file type, you may
encounter anomalous or erroneous file descriptors and corruption errors,
due to certain headers and shared library references in the file being
modified or hidden by the packing program. 

* Running the file command against the suspect binary, the file is identified as being statically 
compiled. Further, the file utility identifies that the section header size is corrupted.

* A suspect executable that is potentially protected with obfuscation code will likely not yield symbolic information.

* Another important clue in identifying that a file has been packed, is the
ELF entry point address. The ELF entry point address generally resides
at an address starting at 0x8048 with the last few bytes varying slightly.