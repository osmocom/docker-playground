;;;
;;; Copyright (c) 2011 Michael Tuexen
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions
;;; are met:
;;; 1. Redistributions of source code must retain the above copyright
;;;    notice, this list of conditions and the following disclaimer.
;;; 2. Redistributions in binary form must reproduce the above copyright
;;;    notice, this list of conditions and the following disclaimer in the
;;;    documentation and/or other materials provided with the distribution.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
;;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
;;; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;;; SUCH DAMAGE.
;;;
;;; $Id: sua-param-testtool-sgp.scm,v 1.2 2011/03/21 22:18:29 tuexen Exp $

;;; Define a transport address of the system under test
(define sut-addr "172.18.0.200")
(define sut-port   sua-port)
(define sut-port-1 sua-port)
(define sut-port-2 (1+ sua-port))

;;; Define the transport address of the tester
(define tester-addr "172.18.0.3")

(define tester-port   0)
(define tester-port-1 3000)
(define tester-port-2 3001)

;;; Define the point code of the SUT
(define sut-pc 1)
;;; Define the SSN of the SUT
(define sut-ssn 3)

;;; Define the point code of the tester
(define tester-pc 24)
(define tester-pc-1 100)
(define tester-pc-2 101)
(define tester-invalid-pc 102)
(define tester-unauthorized-pc 103)
(define tester-unprovisioned-pc 104)

;;; Define the SSN of the tester
(define tester-ssn 3)

;;; Define correlation id
(define correlation-id   1)

;;; Define network appearance
(define network-appearance   1)
(define invalid-network-appearance 2)

;;; Define an routing context
(define tester-rc-valid 1)
(define tester-rc-valid-1 1)
(define tester-rc-valid-2 2)

;;; Define an invalid routing context
(define tester-rc-invalid 3)

;;; Define an asp-identifier
(define asp-id          1)
(define asp-id-1        1)
(define asp-id-2        2)

(define sccp-test-message (list))

;;; Define traffic-type-mode
(define traffic-mode          sua-traffic-mode-type-override)
;(define traffic-mode          sua-traffic-mode-type-loadshare)
;;;(define traffic-mode          sua-traffic-mode-type-broadcast)

(define asp-up-message-parameters (list))
;;; (define asp-up-message-parameters (list (sua-make-asp-id-parameter asp-id)))
;;;asp-up-message-parameters

(define asp-active-message-parameters (list))
;;;(define asp-active-message-parameters (list (sua-make-traffic-mode-type-parameter traffic-mode)
;;;                                            (sua-make-routing-context-parameter (list tester-rc-valid))))
;;;asp-active-message-parameters

(define asp-active-ack-message-parameters (list))
;;;(define asp-active-ack-message-parameters (list (sua-make-traffic-mode-type-parameter traffic-mode)
;;;                                                (sua-make-routing-context-parameter (list tester-rc-valid))))
;;;asp-active-ack-message-parameters

(define asp-inactive-message-parameters (list))
;;;(define asp-inactive-message-parameters (list (sua-make-traffic-mode-type-parameter traffic-mode)
;;;                                              (sua-make-routing-context-parameter (list tester-rc-valid))))
;;;asp-inactive-message-parameters
(define asp-inactive-ack-message-parameters (list))
;;;(define asp-inactive-ack-message-parameters (list (sua-make-routing-context-parameter (list tester-rc-valid))))
;;;asp-inactive-ack-message-parameters

(define data-message-parameters (list))
;;;(define data-message-parameters (list (sua-make-network-appearance-parameter network-appearance)
;;;                                      (sua-make-routing-context-parameter (list tester-rc-valid))))
;;;data-message-parameters

