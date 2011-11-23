;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Contains core key remappings. This file should be run as an independent script,
;;; after all other scripts set up their hooks, putting this script at the top of
;;; the hook chain. That way, all other scripts will see the keys as already being
;;; remapped. If any other hook is installed later (e.g., by vmware or remote
;;; desktop), this script should be reloaded to keep it at the top of the chain.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#SingleInstance force
#NoEnv
SendMode Event
ListLines Off
; Use a separate KeyIgnoreGroup, otherwise other AHK scripts will ignore this
; script's generated input.
#KeyIgnoreGroup 1

;;; Remap browser buttons to mouse buttons
Browser_Back::LButton
Browser_Forward::RButton
