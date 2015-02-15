; echogame, based on "resonabilis - play it yourself"
; users can play a (random) flute sound of a category in given direction and distance in the space


<CsoundSynthesizer>
<CsOptions>
-odac:system:playback_ -+rtaudio=jack -dm0  -b1024  -B2048
;--env:SFDIR=./sounds
</CsOptions>
<CsInstruments>

sr = 44100 
ksmps = 64
nchnls = 2;4
0dbfs = 1

;#define RETURN_TIME #10#

ga1 init 0
ga2 init 0
ga3 init 0
ga4 init 0



; CHANNELS:
chn_k  "bgLevel",1 ; declarations for tetsting in CsoundQt
chn_k  "volume",1
chn_k "returntime",1
chn_k "repeatcount",1

chnset 1, "bgLevel"

; CONSTANTS:
gkBgLevel init 1
gkVolume init 0.6

maxalloc "play", 20 ; was 15 raise!

alwayson "getLevel"
instr getLevel
	k1 chnget "bgLevel"
	gkBgLevel port k1, 0.02
	gkVolume port (chnget:k("volume")),0.02
	;printk2 gkVolume	
endin

;scoreline_i  {{ i "play" 0 0.5 "sounds/medium/short/sound13.wav" 0.5 0 0 }}
instr play
	Sfile strget p4;= "sounds/low/long/sound01.wav";strget p4
	
	;instrument = p4  ; before soundin.number were used
	idegree =  (nchnls==2) ? p5*90 : p5*360 ; comes in as 0..1; cpmvert to stereo - 0..90 or circular  0..360. Front-Left is 0 degrees.
	kdegree init idegree
	idistance = 0.1+p6*3 ; comes in as 0..1>=1 kaugemal
	kdistanceChange init 0
	ivisit = p7 ; first visti - 0, second visit 1 etc
	ireverbtime = 1.5
	ihdif = 0.2 ; the higher, the faster high frequencies decay
	idry = 1 - p6*0.25 ; depending also in distance
	ireturntime chnget "returntime"
	irepeatcount chnget "repeatcount"
	print ireturntime, irepeatcount
		
	if (ivisit < irepeatcount && ireturntime>0) then ; repeat the sound after some time 
		Scmd sprintf "i \"play\" %d 1 \"%s\" %f %f %d", ireturntime, Sfile, p5,p6,p7+1
		prints Scmd
		scoreline_i Scmd
		;schedule "play", ireturntime, 1, p4,p5, p6, p7+1
	endif	
				
	if (ivisit>0 ) then ; second round, not played by performer but invoked as echoe
		kmovement lfo 10,0.4*ivisit,1 ;jitter 90,0.1,1 ; move the angle
		kdegree = idegree +kmovement		
		idistance += 2 * ivisit ; was 0.5*ivisit
		ihdif = 0.2+ivisit/10*0.8
		idry -=  ivisit/10
		kdistanceChange lfo 0.5, 0.25*ivisit,0 ; oli ivist/2
		ireverbtime = 4+ivisit*1.5
		
		
	endif
	
	ireverbsend = 0.005+ 0.01*idistance
	p3=filelen(Sfile)+ireverbtime+0.5 ; give time for reverb ?WHY
	
	print idegree, idistance, ivisit

	adry soundin Sfile ;instrument
	adry = adry*linen:a(1,0.02,filelen(Sfile), 0.2) ; add envelope to soundfile playback
	awet reverb2 adry, 0.2, 0; first small reverb to mimic the room more
	
	asig = adry*idry + awet*(1-idry)
	
	adeclick linen 1.5,0.05,p3,0.5 ; main envelope ; compensate soft sound files
	
	if ivisit >0 then
		asig reverb2 asig*0.2*idry*gkBgLevel,  ireverbtime, ihdif ; TODO: more intereesting reverb with k-parameters, make it depend on some global Kchange
		kfreq line 0.2, p3, 0.5+ivisit/20
		;adel oscil  5+ivisit, kfreq, -1
		;adel += 20
		adel expon 1, p3, 1000*(1+ivisit/10)
		asig vdelay asig, adel, 4000
		asig butterlp asig, 2000-ivisit*180
	endif
	if nchnls==2 then
		kdegree limit kdegree, 0, 90
		;printk2 kdegree
		a1, a2  locsig asig*adeclick*gkVolume, kdegree, idistance, ireverbsend
		ar1, ar2 locsend
		if (ivisit>0) then ; send only repetitions to reverb
			ga1 = ga1 + ar1
			ga2 = (ga2+ar2) 
		endif
		outs  clip(a1*idry,0,0.8), clip(a2*idry,0,0.8) ; make better mix!		
	elseif nchnls==4 then
		a1, a2, a3, a4   locsig asig*adeclick*gkVolume, kdegree, idistance+kdistanceChange, ireverbsend
		ar1, ar2, ar3, ar4 locsend
;		aL reverb2 ar1, ireverbtime, ihdif
;		aR reverb2 ar2, ireverbtime, ihdif
;		aRL reverb2 ar3, ireverbtime, ihdif
;		aRR reverb2 ar4, ireverbtime, ihdif
		if (ivisit>0) then ; send only repetitions to reverb
			ga1 = ga1 + ar1
			ga2 = ga2+ar2 	
			ga3 = ga3 + ar3
			ga4 = ga4+ar4	
		endif
		outq  a1*idry, a2*idry,  a4*idry, a3*idry		
	endif
	
endin


alwayson "reverb_"
giReverbTime init 1;1.5
instr reverb_
	ihdif = 0.5
	aL reverb2 ga1, giReverbTime, ihdif
	aR reverb2 ga2, giReverbTime, ihdif
	outs aL, aR
	if nchnls == 4 then
		a3 reverb2 ga3, giReverbTime, ihdif
		a4 reverb2 ga4, giReverbTime, ihdif
		outq3 a4
		outq4 a3
		ga3 = 0
		ga4 = 0
	
	endif
	ga1=0
	ga2=0
endin


</CsInstruments>
<CsScore>

</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>301</width>
 <height>220</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>bgLevel</objectName>
  <x>90</x>
  <y>79</y>
  <width>94</width>
  <height>22</height>
  <uuid>{617a5234-4109-43b6-8920-2e64ffd9a5b7}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>1.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>volume</objectName>
  <x>91</x>
  <y>30</y>
  <width>100</width>
  <height>34</height>
  <uuid>{1c30bf60-e6a7-4716-a8da-5741b5d2febe}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.45000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>1</x>
  <y>35</y>
  <width>80</width>
  <height>25</height>
  <uuid>{78fa66f6-d72a-4d80-8476-caab9cc127e6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Volume</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>4</x>
  <y>76</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c0da563d-7160-405e-947b-35d5a56fd15c}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Background
</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>10</x>
  <y>138</y>
  <width>80</width>
  <height>25</height>
  <uuid>{3a25c13d-0a92-4084-a3ff-01ef0accef0a}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>Repeat after:</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBHSlider" version="2">
  <objectName>returntime</objectName>
  <x>106</x>
  <y>137</y>
  <width>100</width>
  <height>32</height>
  <uuid>{1467c9d7-ac70-4f0b-8063-9f2adf35c40f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <minimum>3.00000000</minimum>
  <maximum>40.00000000</maximum>
  <value>3.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject type="BSBLabel" version="2">
  <objectName/>
  <x>13</x>
  <y>195</y>
  <width>80</width>
  <height>25</height>
  <uuid>{85c64d1c-a80b-4875-9eb2-6cf931cd43ae}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>N times</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject type="BSBSpinBox" version="2">
  <objectName>repeatcount</objectName>
  <x>112</x>
  <y>193</y>
  <width>80</width>
  <height>25</height>
  <uuid>{06a44878-80a9-42b7-8057-589a03783657}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <resolution>1.00000000</resolution>
  <minimum>0</minimum>
  <maximum>10</maximum>
  <randomizable group="0">false</randomizable>
  <value>0</value>
 </bsbObject>
 <bsbObject type="BSBDisplay" version="2">
  <objectName>returntime</objectName>
  <x>221</x>
  <y>141</y>
  <width>80</width>
  <height>25</height>
  <uuid>{b2160b8b-7802-4a5d-b7ff-e59d371405dc}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <label>3.000</label>
  <alignment>left</alignment>
  <font>Liberation Sans</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
