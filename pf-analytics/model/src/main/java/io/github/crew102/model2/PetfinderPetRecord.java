package io.github.crew102.model2;

import io.github.crew102.model1.pet.Photo;
import io.github.crew102.model2.PetTypes.AgeType;
import io.github.crew102.model2.PetTypes.MixType;
import io.github.crew102.model2.PetTypes.OptionType;
import io.github.crew102.model2.PetTypes.SexType;
import io.github.crew102.model2.PetTypes.SizeType;
import io.github.crew102.model2.PetTypes.StatusType;

public class PetfinderPetRecord {
	
	// fields that will end up in "pet" table
	int pet_id;
	String shelter_id;
	String name;
	StatusType status;
	AgeType age;
	SizeType size;
	SexType sex;
	MixType mix;
	String description;
	
	// fields that create pet_(option|breed|photo) tables
	PetTypes.OptionType[] option;
	String[] breed;
	Photo[] photo;
	
	// needs to be changed to a datetime type 
	String last_update;

    // shelter fields
    String city;
    String state;
    String zip;
    
	public PetfinderPetRecord(int pet_id, String shelter_id, String name, StatusType status, AgeType age, SizeType size,
			SexType sex, MixType mix, String description, OptionType[] option, String[] breed, Photo[] photo,
			String last_update, String city, String state, String zip) {
		this.pet_id = pet_id;
		this.shelter_id = shelter_id;
		this.name = name;
		this.status = status;
		this.age = age;
		this.size = size;
		this.sex = sex;
		this.mix = mix;
		this.description = description;
		this.option = option;
		this.breed = breed;
		this.photo = photo;
		this.last_update = last_update;
		this.city = city;
		this.state = state;
		this.zip = zip;
	}
	
	// for minimal example of parsing
	public PetfinderPetRecord(int pet_id, StatusType status) {
		this.pet_id = pet_id;
		this.status = status;
	}

}
