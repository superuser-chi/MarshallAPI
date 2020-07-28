using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using MarshallAPI.DTO;
using MarshallAPI.Entities;

namespace TransportRequisitionSolution.Services.Helpers {
    public class AutoMapperProfile : Profile {
        public AutoMapperProfile () {
            CreateMap<Kombi, KombiDTO> ()
                .ForMember (dest => dest.OwnerName, opts => opts.MapFrom (src => $"{src.User.Firstname} {src.User.Lastname}"));
            CreateMap<Slot, SlotDTO> ()
                .ForMember (dest => dest.OwnerName, opts => opts.MapFrom (src => $"{src.kombi.User.Firstname} {src.kombi.User.Lastname}"))
                .ForMember (dest => dest.KombiPlate, opts => opts.MapFrom (src => $"{src.kombi.Plate}"))
                .ForMember (dest => dest.RouteName, opts => opts.MapFrom (src => $"{src.Route.From} to {src.Route.To}"));
        }
    }
}