package io.github.crew102.rawresponses;

import java.util.ArrayList;

public class PetfinderPetRecords {
  
  private ArrayList<PetfinderPetRecord> petlist = new ArrayList<PetfinderPetRecord>();
  
  public PetfinderPetRecords(PetfinderPetRecord apet) {
    petlist.add(apet);
  }
  
  public PetfinderPetRecords(PetfinderPetRecord[] pets) {
    for (int i = 0; i < pets.length; i++) {
      PetfinderPetRecord onePet = pets[i];
      petlist.add(onePet);
    }
  }
  
  public ArrayList<PetfinderPetRecord> getPetList() {
    return this.petlist;
  }

}
