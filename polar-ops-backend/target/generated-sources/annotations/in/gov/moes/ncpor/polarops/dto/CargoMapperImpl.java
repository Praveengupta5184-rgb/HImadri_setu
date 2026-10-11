package in.gov.moes.ncpor.polarops.dto;

import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.model.cargo.CargoStatus;
import in.gov.moes.ncpor.polarops.model.cargo.CargoTrackingEvent;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-10-04T12:21:08+0000",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 17.0.11 (Eclipse Adoptium)"
)
@Component
public class CargoMapperImpl implements CargoMapper {

    @Override
    public CargoDto toDto(CargoPackage cargoPackage) {
        if ( cargoPackage == null ) {
            return null;
        }

        CargoDto cargoDto = new CargoDto();

        cargoDto.setId( cargoPackage.getId() );
        cargoDto.setCargoId( cargoPackage.getCargoId() );
        cargoDto.setName( cargoPackage.getName() );
        cargoDto.setDescription( cargoPackage.getDescription() );
        cargoDto.setExpeditionId( cargoPackage.getExpeditionId() );
        cargoDto.setTeamId( cargoPackage.getTeamId() );
        cargoDto.setOwnerOrganization( cargoPackage.getOwnerOrganization() );
        cargoDto.setOrigin( cargoPackage.getOrigin() );
        cargoDto.setDestination( cargoPackage.getDestination() );
        cargoDto.setQuantity( cargoPackage.getQuantity() );
        cargoDto.setWeight( cargoPackage.getWeight() );
        cargoDto.setDimensions( cargoPackage.getDimensions() );
        cargoDto.setCategory( cargoPackage.getCategory() );
        cargoDto.setPriority( cargoPackage.getPriority() );
        if ( cargoPackage.getCurrentStatus() != null ) {
            cargoDto.setCurrentStatus( cargoPackage.getCurrentStatus().name() );
        }
        cargoDto.setHazardousStatus( cargoPackage.getHazardousStatus() );
        cargoDto.setHandlingRequirements( cargoPackage.getHandlingRequirements() );
        cargoDto.setSpecialInstructions( cargoPackage.getSpecialInstructions() );
        cargoDto.setExpectedDeliveryDate( cargoPackage.getExpectedDeliveryDate() );
        cargoDto.setActualDeliveryDate( cargoPackage.getActualDeliveryDate() );
        cargoDto.setCurrentLocation( cargoPackage.getCurrentLocation() );
        cargoDto.setLatitude( cargoPackage.getLatitude() );
        cargoDto.setLongitude( cargoPackage.getLongitude() );
        cargoDto.setLastLocationUpdate( cargoPackage.getLastLocationUpdate() );
        cargoDto.setTrackerId( cargoPackage.getTrackerId() );
        cargoDto.setQrCode( cargoPackage.getQrCode() );
        cargoDto.setRiskScore( cargoPackage.getRiskScore() );
        cargoDto.setCreatedBy( cargoPackage.getCreatedBy() );
        cargoDto.setCreatedAt( cargoPackage.getCreatedAt() );
        cargoDto.setUpdatedAt( cargoPackage.getUpdatedAt() );

        return cargoDto;
    }

    @Override
    public CargoPackage toEntity(CargoDto cargoDto) {
        if ( cargoDto == null ) {
            return null;
        }

        CargoPackage.CargoPackageBuilder cargoPackage = CargoPackage.builder();

        cargoPackage.id( cargoDto.getId() );
        cargoPackage.cargoId( cargoDto.getCargoId() );
        cargoPackage.name( cargoDto.getName() );
        cargoPackage.description( cargoDto.getDescription() );
        cargoPackage.expeditionId( cargoDto.getExpeditionId() );
        cargoPackage.teamId( cargoDto.getTeamId() );
        cargoPackage.ownerOrganization( cargoDto.getOwnerOrganization() );
        cargoPackage.origin( cargoDto.getOrigin() );
        cargoPackage.destination( cargoDto.getDestination() );
        cargoPackage.quantity( cargoDto.getQuantity() );
        cargoPackage.weight( cargoDto.getWeight() );
        cargoPackage.dimensions( cargoDto.getDimensions() );
        cargoPackage.category( cargoDto.getCategory() );
        cargoPackage.priority( cargoDto.getPriority() );
        if ( cargoDto.getCurrentStatus() != null ) {
            cargoPackage.currentStatus( Enum.valueOf( CargoStatus.class, cargoDto.getCurrentStatus() ) );
        }
        cargoPackage.hazardousStatus( cargoDto.getHazardousStatus() );
        cargoPackage.handlingRequirements( cargoDto.getHandlingRequirements() );
        cargoPackage.specialInstructions( cargoDto.getSpecialInstructions() );
        cargoPackage.expectedDeliveryDate( cargoDto.getExpectedDeliveryDate() );
        cargoPackage.actualDeliveryDate( cargoDto.getActualDeliveryDate() );
        cargoPackage.currentLocation( cargoDto.getCurrentLocation() );
        cargoPackage.latitude( cargoDto.getLatitude() );
        cargoPackage.longitude( cargoDto.getLongitude() );
        cargoPackage.lastLocationUpdate( cargoDto.getLastLocationUpdate() );
        cargoPackage.trackerId( cargoDto.getTrackerId() );
        cargoPackage.qrCode( cargoDto.getQrCode() );
        cargoPackage.riskScore( cargoDto.getRiskScore() );
        cargoPackage.createdBy( cargoDto.getCreatedBy() );
        cargoPackage.createdAt( cargoDto.getCreatedAt() );
        cargoPackage.updatedAt( cargoDto.getUpdatedAt() );

        return cargoPackage.build();
    }

    @Override
    public List<CargoDto> toDtoList(List<CargoPackage> cargoPackages) {
        if ( cargoPackages == null ) {
            return null;
        }

        List<CargoDto> list = new ArrayList<CargoDto>( cargoPackages.size() );
        for ( CargoPackage cargoPackage : cargoPackages ) {
            list.add( toDto( cargoPackage ) );
        }

        return list;
    }

    @Override
    public CargoTrackingEventDto toTrackingDto(CargoTrackingEvent event) {
        if ( event == null ) {
            return null;
        }

        CargoTrackingEventDto cargoTrackingEventDto = new CargoTrackingEventDto();

        cargoTrackingEventDto.setCargoId( eventCargoId( event ) );
        cargoTrackingEventDto.setId( event.getId() );
        if ( event.getPreviousStatus() != null ) {
            cargoTrackingEventDto.setPreviousStatus( event.getPreviousStatus().name() );
        }
        if ( event.getNewStatus() != null ) {
            cargoTrackingEventDto.setNewStatus( event.getNewStatus().name() );
        }
        cargoTrackingEventDto.setLocation( event.getLocation() );
        cargoTrackingEventDto.setLatitude( event.getLatitude() );
        cargoTrackingEventDto.setLongitude( event.getLongitude() );
        cargoTrackingEventDto.setEventType( event.getEventType() );
        cargoTrackingEventDto.setPerformedBy( event.getPerformedBy() );
        cargoTrackingEventDto.setRemarks( event.getRemarks() );
        cargoTrackingEventDto.setTimestamp( event.getTimestamp() );

        return cargoTrackingEventDto;
    }

    @Override
    public List<CargoTrackingEventDto> toTrackingDtoList(List<CargoTrackingEvent> events) {
        if ( events == null ) {
            return null;
        }

        List<CargoTrackingEventDto> list = new ArrayList<CargoTrackingEventDto>( events.size() );
        for ( CargoTrackingEvent cargoTrackingEvent : events ) {
            list.add( toTrackingDto( cargoTrackingEvent ) );
        }

        return list;
    }

    private Long eventCargoId(CargoTrackingEvent cargoTrackingEvent) {
        if ( cargoTrackingEvent == null ) {
            return null;
        }
        CargoPackage cargo = cargoTrackingEvent.getCargo();
        if ( cargo == null ) {
            return null;
        }
        Long id = cargo.getId();
        if ( id == null ) {
            return null;
        }
        return id;
    }
}
