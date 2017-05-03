;;; 
;;; Copyright (C) 2004, 2005 M. Tuexen tuexen@fh-muenster.de
;;; 
;;; All rights reserved.
;;; 
;;; Redistribution and use in source and binary forms, with or
;;; without modification, are permitted provided that the
;;; following conditions are met:
;;; 1. Redistributions of source code must retain the above
;;;    copyright notice, this list of conditions and the
;;;    following disclaimer.
;;; 2. Redistributions in binary form must reproduce the
;;;    above copyright notice, this list of conditions and
;;;    the following disclaimer in the documentation and/or
;;;    other materials provided with the distribution.
;;; 3. Neither the name of the project nor the names of
;;;    its contributors may be used to endorse or promote
;;;    products derived from this software without specific
;;;    prior written permission.
;;;  
;;; THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS
;;; ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
;;; BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
;;; MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;;; DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS
;;; BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;;; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
;;; IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;; NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
;;; USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
;;; OF SUCH DAMAGE.

;;; $Id: m3ua-param-testtool.scm,v 1.5 2012/08/28 19:56:13 tuexen Exp $

;;; Define a transport address of the system under test (osmo-stp)
(define sut-addr "172.18.0.200")
(define sut-port   m3ua-port)
(define sut-port-1 m3ua-port)
(define sut-port-2 m3ua-port)

;;; Define the transport address of the tester
(define tester-addr "172.18.0.2")
(define tester-port  3333)
(define tester-port-1 3000)
(define tester-port-2 3001)

;;; Define the point code of the IUT
(define iut-pc 1)

;;; Define the point code of the tester
(define tester-pc 23)
(define tester-pc-1 100)
(define tester-pc-2 101)
(define tester-invalid-pc 102)
(define tester-unauthorized-pc 103)
(define tester-unprovisioned-pc 104)
(define tester-unavailable-pc 1234)
(define tester-available-pc 1235)
(define tester-congested-pc 1236)
(define tester-restricted-pc 1237)

;;; Define a valid SS7 message and SI
(define ss7-message (list 11 34 45 67 67 89))
(define ss7-si      0)

(define iut-ni  1)
(define iut-mp  0)
(define iut-sls 0)


;;; Define correlation id
(define correlation-id   1)

;;; Define network appearance
(define network-appearance   1)
(define invalid-network-appearance 2)

;;; Define an routing context
(define tester-rc-valid 23)
(define tester-rc-valid-1 1)
(define tester-rc-valid-2 2)

;;; Define an invalid routing context
(define tester-rc-invalid 3)

;;; Define an asp-identifier
(define asp-id          1)
(define asp-id-1        1)
(define asp-id-2        2)

;;; Define traffic-type-mode
;;;(define traffic-mode          m3ua-traffic-mode-type-override)
(define traffic-mode          m3ua-traffic-mode-type-loadshare)
;;;(define traffic-mode          m3ua-traffic-mode-type-broadcast)

(define asp-up-message-parameters (list))
;;; (define asp-up-message-parameters (list (m3ua-make-asp-id-parameter asp-id)))
;;;asp-up-message-parameters

(define asp-active-message-parameters (list))
;;;(define asp-active-message-parameters (list (m3ua-make-traffic-mode-type-parameter traffic-mode)
;;;                                            (m3ua-make-routing-context-parameter (list tester-rc-valid))))
;;;asp-active-message-parameters

(define asp-active-ack-message-parameters (list))
;;;(define asp-active-ack-message-parameters (list (m3ua-make-traffic-mode-type-parameter traffic-mode)
;;;                                                (m3ua-make-routing-context-parameter (list tester-rc-valid))))
;;;asp-active-ack-message-parameters

(define asp-inactive-message-parameters (list))
;;;(define asp-inactive-message-parameters (list (m3ua-make-traffic-mode-type-parameter traffic-mode)
;;;                                              (m3ua-make-routing-context-parameter (list tester-rc-valid))))
;;;asp-inactive-message-parameters
(define asp-inactive-ack-message-parameters (list))
;;;(define asp-inactive-ack-message-parameters (list (m3ua-make-routing-context-parameter (list tester-rc-valid))))
;;;asp-inactive-ack-message-parameters

(define data-message-parameters (list))
;;;(define data-message-parameters (list (m3ua-make-network-appearance-parameter network-appearance)
;;;                                      (m3ua-make-routing-context-parameter (list tester-rc-valid))))
;;;data-message-parameters

;;; Define parameter for DATA message
(define rc  23)
(define opc 1)
(define dpc 2)
(define si  0)
(define sls 0)
(define ni  0)
(define mp  0)
(define ss7-message (list 11 34 45 67 67 89))
(define data-message-parameters (list (m3ua-make-routing-context-parameter (list rc))))

