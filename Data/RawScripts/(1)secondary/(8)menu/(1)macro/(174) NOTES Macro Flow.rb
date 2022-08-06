=begin

  # ---------------- #
  # Macro flow notes #
  # ---------------- #
  
  Phase 1 - initialize and confirm macro priority
  Phase 2 - actuation of macro
  
  Macro Phase 2:
    Find (0)character associated with macro:
      Determine if the macro is still usable
      Determine which (0)character is calling macro class
      Determine which target if any targets, are being targetted
      Initialize variables for macro handler
      Initialize variables to handle the macro step flow
      Initialize variables to perform macro flow.
      
      Compare class objects of two individual characters, to determine
        -which variables are to be set using switch statements.
      Compare the resulting switch statement to the map scene to determine
        -where the user belongs when macro is begun
        -where the user belongs after the macro is completed
      Find the battle commands, if battle commands are required.
      Find the resulting battle command calculations after the battle command
        has been used.
        -User statistics vs target statistics
      Depending on requirements in the interpreted macro:
        -Perform the necessary movement, with the animation and graphic changes.
        -Perform the necessary battle animation, with the (0)character sprite changes.
        -Perform the necessary sprite display resets.
        -If needed perform the necessary followup movement with the graphic changes.

=end

